defmodule ExOvh.Ovh.OpenstackApi.Webstorage.Cache do
  @moduledoc :false
  use GenServer
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Supervisor, as: WebStorageSupervisor
  import ExOvh.Query.Ovh.Webstorage, only: [get_webstorage_credentials: 1]
  @get_credentials_retries 10
  @get_credentials_sleep_interval 150


  #####################
  # Public
  #####################


  @doc "Starts the genserver"
  def start_link({client, config, opts}, service) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    GenServer.start_link(__MODULE__, {client, service}, [name: gen_server_name(client, service)])
  end


  def get_credentials(service), do: get_credentials(ExOvh, service)
  def get_credentials(client, service) do
    unless supervisor_exists?(client, service), do: Supervisor.start_child(WebStorageSupervisor, [service])
    get_credentials(client, service, 0)
  end


  def get_credentials_token(service), do: get_credentials_token(ExOvh, service)
  def get_credentials_token(client, service), do: get_credentials(client, service).token


  def get_swift_endpoint(service), do: get_swift_endpoint(ExOvh, service)
  def get_swift_endpoint(client, service) do
    credentials = get_credentials(client, service)
    path = URI.parse(credentials.swift_endpoint) |> Map.get(:path)
    {version, account} = String.split_at(path, 4)
    endpoint = List.first(String.split(credentials.swift_endpoint, account))
    endpoint
  end


  def get_account(service), do: get_account(ExOvh)
  def get_account(client, service) do
    credentials = get_credentials(client, service)
    path = URI.parse(credentials.swift_endpoint) |> Map.get(:path)
    {version, account} = String.split_at(path, 4)
    account
  end


  #####################
  # Genserver Callbacks
  #####################


  # trap exits so that terminate callback is invoked
  # the :lock key is to allow for locking during the brief moment that the access token is being refreshed
  def init({client, service}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    :erlang.process_flag(:trap_exit, :true)
    create_ets_table(client, service)
    {:ok, credentials} = identity(service)
    credentials = Map.put(credentials, :lock, :false)
    :ets.insert(ets_tablename(client, service), {:credentials, credentials})
    expires = to_seconds(credentials.token_expires_on)
    Task.start_link(fn -> monitor_expiry(expires) end)
    {:ok, {client, service, credentials}}
  end

  def handle_call(:add_lock, _from, {client, service, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_credentials = Map.put(credentials, :lock, :true)
    :ets.insert(ets_tablename(client, service), {:credentials, new_credentials})
    {:reply, :ok, {client, service, new_credentials}}
  end

  def handle_call(:remove_lock, _from, {client, service, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    new_credentials = Map.put(credentials, :lock, :false)
    :ets.insert(ets_tablename(client, service), {:credentials, new_credentials})
    {:reply, :ok, {client, service, new_credentials}}
  end

  def handle_call(:update_credentials, _from, {client, service, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:ok, new_credentials} = identity(service)
    |> Map.put(credentials, :lock, :false)
    :ets.insert(ets_tablename(client, service), {:credentials, new_credentials})
    {:reply, :ok, {client, service, new_credentials}}
  end

  def handle_call(:stop, _from, state) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {:stop, :shutdown, :ok, state}
  end

  def terminate(:shutdown, {client, service, credentials}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    :ets.delete(ets_tablename(client, service)) # explicilty remove
    :ok
  end



  #####################
  # Private
  #####################

  defp gen_server_name(client, service), do:  String.to_atom(Atom.to_string(client) <> service)
  defp ets_tablename(client, service), do: String.to_atom(Atom.to_string(client) <> "-" <> service)


  #@spec identity(service :: String.t, username :: String.t, password :: String.t)
  #               :: {:ok, map()} | {:error, map()} ??
  # This function probably should be broken down into smaller parts
  def identity(service) do

    {:ok, resp} = ExOvh.ovh_request(get_webstorage_credentials(service), %{})

    %{
      "endpoint" => endpoint,
      "login" => login,
      "password" => password,
      "tenant" => tenant
    } = resp.body

    params = %{"auth" =>
                        %{
                        "passwordCredentials" => %{"username" => login, "password" => password}
                        }
              }
    options = %{
                body: params |> Poison.encode!,
                headers: %{ "Content-Type": "application/json; charset=utf-8" },
                timeout: 10_000
               }
    resp = HTTPotion.request(:post, endpoint <> "/tokens", options)

    unless resp.status_code >= 200 and resp.status_code <= 203, do: raise resp.body

    %{
      "access" =>
                  %{
                    "token" => %{
                                 "expires" => expires_on,
                                 "id" => token,
                                 "issued_at" => created_on
                                },
                  }
      } = Poison.decode!(resp.body)

    params = %{"auth" =>
                        %{
                        "tenantName" => tenant,
                        "token" => %{"id" => token}}
                        }
    options = %{
                body: params |> Poison.encode!,
                headers: %{ "Content-Type": "application/json; charset=utf-8" },
                timeout: 10_000
               }
    resp = HTTPotion.request(:post, endpoint <> "/tokens", options)

    unless resp.status_code >= 200 and resp.status_code <= 203, do: raise resp.body

    %{
      "serviceCatalog" => [
                          %{
                            "endpoints" => [%{"publicURL" => swift_endpoint}],
                            "name" => "swift",
                          },
                          %{
                            "endpoints" => [%{"publicURL" => identity_endpoint}],
                            "name" => "keystone",
                          }
                         ],
                          "token" => %{
                                          "expires" => token_expires_on,
                                          "id" => token,
                                          "issued_at" => token_created_on,
                                        },
                          "user" => _user
      } = Poison.decode!(resp.body) |> Map.get("access")

      {:ok,
          %{
            token: token,
            token_expires_on: expires_on,
            token_created_on: token_created_on,
            swift_endpoint: swift_endpoint,
            identity_endpoint: identity_endpoint,
            service: service
          }
      }

  end


  defp get_credentials(client, service, index) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    if ets_tablename(client, service) in :ets.all() do
      [credentials: credentials] = :ets.lookup(ets_tablename(client, service), :credentials)
      if credentials.lock === :true do
        if index > @get_credentials_retries do
          raise "Cannot retrieve openstack credentials from ets table, #{__ENV__.module}, #{__ENV__.line}"
        else
          :timer.sleep(@get_credentials_sleep_interval)
          get_credentials(client, service, index + 1)
        end
      else
        credentials
      end
    else
      if index > @get_credentials_retries do
        raise "Cannot retrieve openstack credentials from ets table, #{__ENV__.module}, #{__ENV__.line}"
      else
        :timer.sleep(@get_credentials_sleep_interval)
        get_credentials(client, service, index + 1)
      end
    end
  end


  defp monitor_expiry(expires) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    interval = (expires - 30) * 1000
    :timer.sleep(interval)
    {:reply, :ok, _credentials} = GenServer.call(self(), :add_lock)
    {:reply, :ok, _credentials} = GenServer.call(self(), :update_credentials)
    {:reply, :ok, credentials} = GenServer.call(self(), :remove_lock)
    expires = to_seconds(credentials["expires"])
    monitor_expiry(expires)
  end


  defp create_ets_table(client, service) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    ets_options = [
                   :set, # type
                   :protected, # read - all, write this process only.
                   :named_table,
                   {:heir, :none}, # don't let any process inherit the table. when the ets table dies, it dies.
                   {:write_concurrency, :false},
                   {:read_concurrency, :true}
                  ]
    unless ets_tablename(client, service) in :ets.all() do
      :ets.new(ets_tablename(client, service), ets_options)
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


  defp supervisor_exists?(client, service) do
    Process.whereis(registered_supervisor_name(client, service))
  end


  defp registered_supervisor_name(client, service) do
    String.to_atom(Atom.to_string(client) <> service)
  end


end