defmodule ExOvh.Auth.Openstack.Swift.Cache do
  @moduledoc :false
  use GenServer
  use Openstex.Cache
  alias ExOvh.Auth.Openstack.Swift.Cache.Cloudstorage
  alias ExOvh.Auth.Openstack.Swift.Cache.Webstorage
  alias Openstex.Keystone.V2.Helpers, as: Keystone
  alias Openstex.Keystone.V2.Helpers.Identity
  import ExOvh.Utils, only: [ets_tablename: 1]
  @get_identity_retries 5
  @get_identity_interval 1000


  # Public


  def start_link({ovh_client, swift_client}) do
    Og.context(__ENV__, :debug)
    GenServer.start_link(__MODULE__, {ovh_client, swift_client}, [name: swift_client])
  end

  # Pulic Opestex.Cache callbacks (public 'interface' to the Cache module)

  def get_swift_public_url(swift_client) do
    public_url = get_identity(swift_client)
    |> Map.get(:service_catalog)
    |> Enum.find(fn(%Identity.Service{} = service) ->  service.name == "swift" end)
    |> Map.get(:endpoints)
    |> Enum.find(fn(%Identity.Endpoint{} = endpoint) ->  endpoint.region == swift_client.config()[:region] end)
    |> Map.get(:public_url)
  end

  # get_swift_endpoint/1-- use default implementation for `use Openstex.Cache`.
  # get_swift_account/1 -- use default implementation for `use Openstex.Cache`.

  def get_xauth_token(swift_client) do
    get_identity(swift_client) |> Map.get(:token) |> Map.get(:id)
  end


  # Genserver Callbacks


  # trap exits so that terminate callback is invoked
  # the :lock key is to allow for locking during the brief moment that the access token is being refreshed
  def init({ovh_client, swift_client}) do
    Og.context(__ENV__, :debug)
    :erlang.process_flag(:trap_exit, :true)
    create_ets_table(swift_client)
    config = swift_client.config()
    identity = create_identity({ovh_client, swift_client}, config, config[:type])
    identity = Map.put(identity, :lock, :false)
    :ets.insert(ets_tablename(swift_client), {:identity, identity})
    try_to_set_temp_url_key(swift_client)
    expiry = to_seconds(identity)
    Task.start_link(fn -> monitor_expiry(expiry) end)
    {:ok, {swift_client, identity}}
  end

  def handle_call(:add_lock, _from, {swift_client, identity}) do
    Og.context(__ENV__, :debug)
    new_identity = Map.put(identity, :lock, :true)
    :ets.insert(ets_tablename(swift_client), {:identity, new_identity})
    {:reply, :ok, {swift_client, new_identity}}
  end

  def handle_call(:remove_lock, _from, {swift_client, identity}) do
    Og.context(__ENV__, :debug)
    new_identity = Map.put(identity, :lock, :false)
    :ets.insert(ets_tablename(swift_client), {:identity, new_identity})
    {:reply, :ok, {swift_client, new_identity}}
  end

  def handle_call(:update_identity, _from, {swift_client, identity}) do
    Og.context(__ENV__, :debug)
    {:ok, new_identity} = get_identity(swift_client)
    |> Map.put(identity, :lock, :false)
    :ets.insert(ets_tablename(swift_client), {:identity, new_identity})
    {:reply, :ok, {swift_client, new_identity}}
  end

  def handle_call(:stop, _from, state) do
    Og.context(__ENV__, :debug)
    {:stop, :shutdown, :ok, state}
  end

  def terminate(:shutdown, {swift_client, identity}) do
    Og.context(__ENV__, :debug)
    :ets.delete(ets_tablename(swift_client)) # explicilty remove
    :ok
  end


  # private


  defp create_identity({ovh_client, swift_client}, config, :webstorage) do
    Og.context(__ENV__, :debug)
    Webstorage.create_identity({ovh_client, swift_client}, config)
  end
  defp create_identity({ovh_client, swift_client}, config, :cloudstorage) do
    Og.context(__ENV__, :debug)
    Cloudstorage.create_identity({ovh_client, swift_client}, config)
  end
  defp create_identity({ovh_client, swift_client}, config, type) do
    Og.context(__ENV__, :debug)
    raise "create_identity/3 is only supported for the :webstorage and :cloudstorage types, #{inspect(type)}"
  end


  defp try_to_set_temp_url_key(swift_client) do
    if Keyword.has_key?(swift_client.config(), :temp_url_key) do
      temp_key = Keyword.get(swift_client.config() |> Og.log_return(__ENV__), :temp_url_key, :nil)
      |> Og.log_return(__ENV__)
      account = swift_client.account()
      if temp_key != :nil do
        resp = Openstex.Swift.V1.Query.account_info(account) |> swift_client.request!()
        unless Map.has_key?(resp.headers, "X-Account-Meta-Temp-Url-Key") do
          %Openstex.Openstack.Swift.Query{method: :post, uri: account, params: :nil}
          |> swift_client.prepare_request()
          |> Openstex.Utils.put_http_headers(%{"X-Account-Meta-Temp-URL-Key" => temp_key})
          |> swift_client.request!()
        end
      end
    end
  end


  defp get_identity(swift_client) do
      get_identity(swift_client, 0)
  end
  defp get_identity(swift_client, index) do
    Og.context(__ENV__, :debug)

    retry = fn(swift_client, index) ->
      if index > @get_identity_retries do
        raise "Cannot retrieve openstack identity, #{__ENV__.module}, #{__ENV__.line}, client: #{swift_client}"
      else
        :timer.sleep(@get_identity_interval)
        get_identity(swift_client, index + 1)
      end
    end

    if ets_tablename(swift_client) in :ets.all() do
      table = :ets.lookup(ets_tablename(swift_client), :identity)
      case table do
        [identity: identity] ->
          if identity.lock === :true do
            retry.(swift_client, index)
          else
            identity
          end
        [] -> retry.(swift_client, index)
      end
    else
      retry.(swift_client, index)
    end

  end


  defp monitor_expiry(expires) do
    Og.context(__ENV__, :debug)
    interval = (expires - 30) * 1000
    :timer.sleep(interval)
    {:reply, :ok, _identity} = GenServer.call(self(), :add_lock)
    {:reply, :ok, _identity} = GenServer.call(self(), :update_identity)
    {:reply, :ok, identity} = GenServer.call(self(), :remove_lock)
    identity |> Og.log_return(__ENV__, :debug)
    expires = to_seconds(identity.token.expires)
    monitor_expiry(expires)
  end


  defp create_ets_table(swift_client) do
    Og.context(__ENV__, :debug)
    ets_options = [
                   :set, # type
                   :protected, # read - all, write this process only.
                   :named_table,
                   {:heir, :none}, # don't let any process inherit the table. when the ets table dies, it dies.
                   {:write_concurrency, :false},
                   {:read_concurrency, :true}
                  ]
    unless ets_tablename(swift_client) in :ets.all() do
      :ets.new(ets_tablename(swift_client), ets_options)
    end
  end


  defp to_seconds(identity) do
    identity |> Og.log_return(__ENV__, :debug)
    iso_time = identity.token.expires
    {:ok, expiry_ndt, offset} = Calendar.NaiveDateTime.Parse.iso8601(iso_time)
    offset =
    case offset do
      :nil -> 0
      offset -> offset
    end
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