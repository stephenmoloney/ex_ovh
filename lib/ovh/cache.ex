defmodule ExOvh.Ovh.Cache do
  @moduledoc ~s"""
    Caches the ovh api time diff
  """
  use GenServer
  alias ExOvh.Ovh.Defaults

  ############################
  # Public
  ###########################

  @doc "Starts a genserver to keep state on the config and time diff"
  def start_link({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    GenServer.start_link(__MODULE__, {client, config, opts}, [name: gen_server_name(client)])
  end


  @doc "Retrieves the ovh api time diff from the cache"
  def get_time_diff(client) do
    GenServer.call(gen_server_name(client), :get_diff)
  end
  @doc "Retrieves the ovh config map"
  def get_config(client) do
    GenServer.call(gen_server_name(client), :get_config)
  end


  ############################
  # Genserver Callbacks
  ###########################

  def init({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    LoggingUtils.log_return({client, config, opts}, :warn)
    diff = calculate_diff(config)
    {:ok, {config, diff}}
  end

  def handle_call(:get_diff, _from, {config, diff}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:reply, diff, {config, diff}}
  end

  def handle_call(:get_config, _from, {config, diff}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:reply, config, {config, diff}}
  end

  def handle_cast({:set_diff, new_diff}, {config, diff}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:noreply, {config, new_diff}}
  end

  def terminate(:shutdown, state) do
    LoggingUtils.log_mod_func_line(__ENV__, :warn)
    LoggingUtils.log_return("gen_server #{__MODULE__} shutting down", :warn)
    :ok
  end


  ############################
  # Private
  ###########################


  defp gen_server_name(client), do: String.to_atom(Atom.to_string(client) <> Atom.to_string(__MODULE__))
  defp endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  defp api_version(config), do: config[:api_version]


  defp api_time_request(config) do
    time_uri = endpoint(config) <> api_version(config) <> "/auth/time"
    options = [ headers: ["Content-Type": "application/json; charset=utf-8"], timeout: 10_000 ]
    api_time = HTTPotion.request(:get, time_uri, options) |> Map.get(:body) |> Poison.decode!()
  end


  defp calculate_diff(config) do
    api_time = api_time_request(config)
    os_t = :os.system_time(:seconds)
    os_t - api_time
  end


  #Caches the ovh api time diff
  defp set_time_diff(client) do
    config = get_config(client)
    set_time_diff(client, config)
  end
  defp set_time_diff(client, config) when is_map(config) do
    diff = calculate_diff(config)
    GenServer.cast(gen_server_name(client), {:set_diff, diff})
  end


end