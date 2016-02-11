defmodule ExOvh.Hubic.HubicApi.Cache do
  @moduledoc ~s"""
  Caches the access_token and provides a simple get_token() api to other modules through one function get_token()
  Caches the hubic config map.

  Maintains the access token so that:
  - State is maintained in gen_server state but gen_server could be a bottleneck so it is also copied to a public ets table.
  - So state is also stored in an ets table and is quickly and globally retrievable.
  - State in :ets and :gen_server should be synchronised.
  - It is automatically refreshed in the background when it expires
  - If the gen_server crashes, it will attempt to re-establish the access token
  - The refresh token by attempting the following:
    - 1. Firstly, try to recuperate the refresh_token from a dets entry.
    - 2. Secondly, by checking for the refresh_token in the config secret file.
  - If both of the above methods fail, then ultimately the gen_server will crash and the user
    will have to retrieve another refresh_token using the `mix hubic` task

  tokens is a map with the following structure:
  - `%{
       :lock => :true,
       "access_token" => "access_token",
       "expires_in" => 21600,
       "refresh_token" => "refresh_token",
       "token_type" => "Bearer"
    }`
  """
  use GenServer
  alias ExOvh.Hubic.HubicApi.Auth
  @get_token_retries 20
  @get_token_sleep_interval 300


  #####################
  # Public
  #####################


  @doc "Starts the genserver"
  def start_link({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    GenServer.start_link(__MODULE__, {client, config, opts}, [name: gen_server_name(client)])
  end


  @doc "Gets the access_token from the :ets table"
  @spec get_token() :: String.t
  def get_token(), do: get_token(ExOvh, 0)

  @doc "Gets the access_token from the :ets table"
  @spec get_token(client :: atom) :: String.t
  def get_token(client), do: get_token(client, 0)

  @doc "Retrieves the hubic config map"
  def get_config(client) do
    GenServer.call(gen_server_name(client), :get_config)
  end


  #####################
  # Genserver Callbacks
  #####################

  # trap exits so that terminate callback is invoked
  # the :lock key is to allow for locking during the brief moment that the access token is being refreshed
  def init({client, config, _opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    :erlang.process_flag(:trap_exit, :true)
    create_ets_table(client)
    refresh_token = config.refresh_token
    case refresh_token  do
      :nil -> # RAISE AN EXCEPTION DUE TO UNAVAILABILITY OF THE REFRESH TOKEN
        error = "Valid refresh token not available"
        LoggingUtils.log_return(error, :error)
        raise error
      refresh_token -> # TRY TO GET REFRESH TOKEN FROM THE CONFIG
        tokens = get_latest_tokens(%{"refresh_token" => refresh_token}, config) |> Map.put(:lock, :false)
        :ets.insert(ets_tablename(client), {:tokens, tokens})
        Task.start_link(fn -> monitor_expiry(client, tokens["expires_in"]) end)
        {:ok, {client, config, tokens}}
    end
  end

  def handle_call(:add_lock, _from, {client, config, tokens}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_tokens = Map.put(tokens, :lock, :true)
    :ets.insert(ets_tablename(client), {:tokens, new_tokens})
    {:reply, :ok, new_tokens}
  end

  def handle_call(:remove_lock, _from, {client, config, tokens}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_tokens = Map.put(tokens, :lock, :false)
    :ets.insert(ets_tablename(client), {:tokens, new_tokens})
    {:reply, :ok, new_tokens}
  end

  def handle_call(:update_tokens, _from, {client, config, tokens}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_tokens = get_latest_tokens(tokens, config)
    |> Map.put(tokens, :lock, :false)
    :ets.insert(ets_tablename(client), {:tokens, new_tokens})
    {:reply, :ok, {client, new_tokens}}
  end

  def handle_call(:get_config, _from, {client, config, tokens}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:reply, config, {client, config, tokens}}
  end

  def handle_call(:stop, _from, {client, config, tokens}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:stop, :shutdown, :ok, {client, config, tokens}}
  end

  def terminate(:shutdown, {client, config, tokens}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    :ets.delete(ets_tablename(client))
    :ok
  end


  #####################
  # Private
  #####################

  defp gen_server_name(client), do: String.to_atom(Atom.to_string(client) <> Atom.to_string(__MODULE__))
  defp ets_tablename(client), do: String.to_atom("Ets" <> Atom.to_string(gen_server_name(client)))

  # get the token from the :ets table
  defp get_token(client, index) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    if ets_tablename(client) in :ets.all() do
      [tokens: tokens] = :ets.lookup(ets_tablename(client), :tokens)
      if tokens.lock === :true do
        if index > @get_token_retries do
          raise "Problem retrieving the access token from ets table"
        else
          :timer.sleep(@get_token_sleep_interval)
          get_token(client, index + 1)
        end
      else
        tokens["access_token"]
      end
    else
      if index > @get_token_retries do
        raise "Problem retrieving the access token from ets table"
      else
        :timer.sleep(@get_token_sleep_interval)
        get_token(client, index + 1)
      end
    end
  end


  # Returns a map in following format with the latest tokens:
  # %{"access_token" => "access_token", "expires_in" => 21600, "refresh_token" => "refresh_token", "token_type" => "Bearer"}
  defp get_latest_tokens(tokens, config) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    Auth.get_latest_access_token(tokens["refresh_token"], config)
    |> Map.put("refresh_token", tokens["refresh_token"])
  end

  # Recursive function
  # Modifies the gen_server state every time the access_token expiry is within 30 seconds of expiry.
  # expires_in parameter is in seconds
  # This function is used as a worker `Task` everytime the genserver is initialised.
  defp monitor_expiry(client, expires_in) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    interval = (expires_in - 30) * 1000
    :timer.sleep(interval)
    {:reply, :ok, _state} = GenServer.call(gen_server_name(client), :add_lock)
    {:reply, :ok, _state} = GenServer.call(gen_server_name(client), :update_tokens)
    {:reply, :ok, state} = GenServer.call(gen_server_name(client), :remove_lock)
    monitor_expiry(client, state["expires_in"])
  end

  # creates the ets table
  defp create_ets_table(client) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    ets_options = [
                   :set, # type
                   :protected, # read - all, write this process only.
                   :named_table,
                   {:heir, :none}, # don't let any process inherit the table. when the ets table dies, it dies.
                   {:write_concurrency, :false},
                   {:read_concurrency, :true}
                  ]
    unless ets_tablename(client) in :ets.all() do
      :ets.new(ets_tablename(client), ets_options)
    end
  end


end