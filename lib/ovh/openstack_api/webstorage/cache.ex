defmodule ExOvh.Ovh.OpenstackApi.Webstorage.Cache do
  @moduledoc """
  Caches the openstack credentials for access to the openstack api associated with the webstorage cdn.

  Uses the standard Openstack Identity (Keystone) api for auth.
  """
  use GenServer
  alias ExOvh.Hubic.HubicApi.Cache
  alias ExOvh.Hubic.Request
  import ExOvh.Query.Ovh.Webstorage
  @get_credentials_retries 10
  @get_credentials_sleep_interval 150


  #####################
  # Public
  #####################


  @doc "Starts the genserver"
  def start_link({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    GenServer.start_link(__MODULE__, {client, config, opts}, [name: gen_server_name(client)])
  end


  def get_credentials(), do: get_credentials(ExOvh)
  def get_credentials(client), do: get_credentials(client, 0)


  def get_credentials_token(), do: get_credentials_token(ExOvh)
  def get_credentials_token(client), do: get_credentials(client)["token"]


  def get_endpoint(), do: get_endpoint(ExOvh)
  def get_endpoint(client) do
    credentials = get_credentials(client)
    path = URI.parse(credentials["endpoint"])
    |> Map.get(:path)
    {version, account} = String.split_at(path, 4)
    endpoint = List.first(String.split(credentials["endpoint"], account))
    endpoint
  end


  #####################
  # Genserver Callbacks
  #####################


  # trap exits so that terminate callback is invoked
  # the :lock key is to allow for locking during the brief moment that the access token is being refreshed
  def init({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    :erlang.process_flag(:trap_exit, :true)
    create_ets_table(client)

    {:ok, resp} = Request.request(client, {:get, "/account/credentials", ""}, %{})
    |> LoggingUtils.log_return(:debug)


    credentials = Map.put(resp.body, :lock, :false)
    :ets.insert(ets_tablename(client), {:credentials, credentials})
    expires = to_seconds(credentials["expires"])
    Task.start_link(fn -> monitor_expiry(client, expires) end)
    {:ok, {client, config, credentials}}
  end


  def handle_call(:add_lock, _from, {client, config, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_credentials = Map.put(credentials, :lock, :true)
    :ets.insert(ets_tablename(client), {:credentials, new_credentials})
    {:reply, :ok, {client, config, new_credentials}}
  end
  def handle_call(:remove_lock, _from, {client, config, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_credentials = Map.put(credentials, :lock, :false)
    :ets.insert(ets_tablename(client), {:credentials, new_credentials})
    {:reply, :ok, {client, config, new_credentials}}
  end
  def handle_call(:update_credentials, _from, {client, config, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:ok, resp} = Request.request(client, {:get, "/account/credentials", ""}, %{})
    new_credentials = resp.body
    |> Map.put(credentials, :lock, :false)
    :ets.insert(ets_tablename(client), {:credentials, new_credentials})
    {:reply, :ok, {client, config, new_credentials}}
  end
  def handle_call(:stop, _from, state) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:stop, :shutdown, :ok, state}
  end
  def terminate(:shutdown, {client, config, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    :ets.delete(ets_tablename(client)) # explicilty remove
    :ok
  end



  #####################
  # Private
  #####################

  defp gen_server_name(client), do: String.to_atom(Atom.to_string(client) <> Atom.to_string(__MODULE__))
  defp ets_tablename(client), do: String.to_atom("Ets" <> Atom.to_string(gen_server_name(client)))


  #@spec identity(service_name :: String.t, username :: String.t, password :: String.t)
  #               :: {:ok, map()} | {:error, map()}
  defp identity(service_name, username, password) do
    resp = ExOvh.ovh_request(get_webstorage_credentials(service_name), %{})
    %{
      "endpoint" => endpoint,
      "login" => login,
      "password" => password,
      "tenant" => tenant
    } = resp.body
    params = %{"auth" => %{"passwordCredentials" => %{"username" => login, "password" => password}}}
    options = %{
                body: params |> Poison.encode!,
                headers: %{ "Content-Type": "application/json; charset=utf-8" },
                timeout: 10_000
               }
    resp = HTTPotion.request(:post, endpoint <> "/tokens", options)

    if resp.status_code >= 200 and resp.status_code <= 203 do
      %{
         "access" => %{
                      "metadata" => _metadata,
                      "serviceCatalog" => _service_catalog,
                      "token" => %{
                                  "audit_ids" => _audit_ids,
                                  "expires" => expires_on, # "2016-02-12T22:12:25Z",
                                  "id" => token,
                                  "issued_at" => created_on, # "2016-02-11T22:12:25.214186"
                                  },
                      "user" => _user
                     }
      }
      = resp.body
      {:ok, %{ "token" => token, "expires_on" => expires_on, "created_on" => created_on, "endpoint" => endpoint } }
    else
      {:error, resp.body}
    end

  end


  defp get_credentials(client, index) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    if ets_tablename(client) in :ets.all() do
      [credentials: credentials] = :ets.lookup(ets_tablename(client), :credentials)
      if credentials.lock === :true do
        if index > @get_credentials_retries do
          raise "Problem retrieving the openstack credentials from ets table"
        else
          :timer.sleep(@get_credentials_sleep_interval)
          get_credentials(client, index + 1)
        end
      else
        credentials
      end
    else
      if index > @get_credentials_retries do
        raise "Problem retrieving the openstack credentials from ets table"
      else
        :timer.sleep(@get_credentials_sleep_interval)
        get_credentials(client, index + 1)
      end
    end
  end


  defp monitor_expiry(client, expires) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    interval = (expires - 30) * 1000
    :timer.sleep(interval)
    {:reply, :ok, _credentials} = GenServer.call(gen_server_name(client), :add_lock)
    {:reply, :ok, _credentials} = GenServer.call(gen_server_name(client), :update_credentials)
    {:reply, :ok, credentials} = GenServer.call(gen_server_name(client), :remove_lock)
    expires = to_seconds(credentials["expires"])
    monitor_expiry(client, expires)
  end


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


  defp to_seconds(iso_time) do
    {:ok, expiry_ndt, offset} = Calendar.NaiveDateTime.Parse.iso8601(iso_time)
    {:ok, expiry_dt_utc} = Calendar.NaiveDateTime.with_offset_to_datetime_utc(expiry_ndt, offset)
    {:ok, now} = Calendar.DateTime.from_erl(:calendar.universal_time(), "UTC")
    {:ok, seconds, _microseconds, _when} = Calendar.DateTime.diff(expiry_dt_utc, now)
    if seconds > 0 do
      seconds
    else
      0
    end
  end


end