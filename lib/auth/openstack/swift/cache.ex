defmodule ExOvh.Auth.Openstack.Swift.Cache do
  @moduledoc :false
  use GenServer
  use Openstex.Cache
  alias ExOvh.Auth.Openstack.Swift.Cache.Cloudstorage
  alias ExOvh.Auth.Openstack.Swift.Cache.Webstorage
  alias ExOvh.Auth.Openstack.Supervisor, as: OpenstackSupervisor
  alias ExOvh.Utils
  alias Openstex.Helpers.V2.Keystone
  alias Openstex.Helpers.V2.Keystone.Identity
  import ExOvh.Utils, only: [gen_server_name: 1, ets_tablename: 1]
  @get_identity_retries 5
  @get_identity_interval 1000


  # Public


  def start_link(client) do
    Og.context(__ENV__, :debug)
    GenServer.start_link(__MODULE__, client, [name: gen_server_name(client)])
  end

  # Pulic Opestex.Cache callbacks (public 'interface' to the Cache module)

  def get_swift_account(client) do
    public_url = get_identity(client)
    |> Map.get(:service_catalog)
    |> Enum.find(fn(%Identity.Service{} = service) ->  service.name == "swift" end)
    |> Map.get(:endpoints)
    |> List.first()
    |> Map.get(:public_url)

    path = URI.parse(public_url) |> Map.get(:path)
    {version, account} = String.split_at(path, 4)
    account
  end

  def get_swift_endpoint(client) do
    public_url = get_identity(client)
    |> Map.get(:service_catalog)
    |> Enum.find(fn(%Identity.Service{} = service) ->  service.name == "swift" end)
    |> Map.get(:endpoints)
    |> List.first()
    |> Map.get(:public_url)

    path = URI.parse(public_url) |> Map.get(:path)
    {version, account} = String.split_at(path, 4)
    endpoint = String.split(public_url, account) |> List.first()
    endpoint
  end

  def get_xauth_token(client) do
    get_identity(client) |> Map.get(:token) |> Map.get(:id)
  end


  # Genserver Callbacks


  # trap exits so that terminate callback is invoked
  # the :lock key is to allow for locking during the brief moment that the access token is being refreshed
  def init(client) do
    Og.context(__ENV__, :debug)
    :erlang.process_flag(:trap_exit, :true)
    create_ets_table(client)



    ## Get the client id from the config ??
    Og.context(__ENV__, :debug)
    config = get_config(client)
    |> Og.log_return(__ENV__, :warn)

    {:ok, identity} = create_identity(client, config, config[:type])
    Og.context(__ENV__, :debug)

    identity = Map.put(identity, :lock, :false)
    :ets.insert(ets_tablename(client), {:identity, identity})
    expiry = to_seconds(identity)
    Task.start_link(fn -> monitor_expiry(expiry) end)
    {:ok, {client, identity}}
  end

  def handle_call(:add_lock, _from, {client, identity}) do
    Og.context(__ENV__, :debug)
    new_identity = Map.put(identity, :lock, :true)
    :ets.insert(ets_tablename(client), {:identity, new_identity})
    {:reply, :ok, {client, new_identity}}
  end

  def handle_call(:remove_lock, _from, {client, identity}) do
    Og.context(__ENV__, :debug)
    new_identity = Map.put(identity, :lock, :false)
    :ets.insert(ets_tablename(client), {:identity, new_identity})
    {:reply, :ok, {client, new_identity}}
  end

  def handle_call(:update_identity, _from, {client, identity}) do
    Og.context(__ENV__, :debug)
    {:ok, new_identity} = get_identity(client)
    |> Map.put(identity, :lock, :false)
    :ets.insert(ets_tablename(client), {:identity, new_identity})
    {:reply, :ok, {client, new_identity}}
  end

  def handle_call(:stop, _from, state) do
    Og.context(__ENV__, :debug)
    {:stop, :shutdown, :ok, state}
  end

  def terminate(:shutdown, {client, identity}) do
    Og.context(__ENV__, :debug)
    :ets.delete(ets_tablename(client)) # explicilty remove
    :ok
  end


  # private


  defp create_identity(client, config, :webstorage) do
    Og.context(__ENV__, :debug)
    Webstorage.create_identity(client, config)
  end
  defp create_identity(client, config, :cloudstorage) do
    Og.context(__ENV__, :debug)
    Cloudstorage.create_identity(client, config)
  end
  defp create_identity(client, config, type) do
    Og.context(__ENV__, :debug)
    raise "create_identity/3 is only supported for the :webstorage and :cloudstorage types, #{inspect(type)}"
  end


  defp get_identity(client) do
    if supervisor_exists?(client) do
      get_identity(client, 0)
    else
      case Supervisor.start_child(OpenstackSupervisor, [client]) do
        {:error, error} -> raise inspect(error)
        {:ok, _} ->
          if supervisor_exists?(client) do
            get_identity(client, 0)
          else
            raise Og.log_return("", __ENV__, :error) |> inspect()
          end
      end
    end
  end
  defp get_identity(client, index) do
    Og.context(__ENV__, :debug)

    retry = fn(client, index) ->
      if index > @get_identity_retries do
        raise "Cannot retrieve openstack identity, #{__ENV__.module}, #{__ENV__.line}, client: #{client}"
      else
        :timer.sleep(@get_identity_interval)
        get_identity(client, index + 1)
      end
    end

    if ets_tablename(client) in :ets.all() do
      table = :ets.lookup(ets_tablename(client), :identity)
      case table do
        [identity: identity] ->
          if identity.lock === :true do
            retry.(client, index)
          else
            identity
          end
        [] -> retry.(client, index)
      end
    else
      retry.(client, index)
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


  defp create_ets_table(client) do
    Og.context(__ENV__, :debug)
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


  defp supervisor_exists?(client) do
    registered_name = gen_server_name(client)
    |> Og.log_return(__ENV__, :debug)
    case Process.whereis(registered_name) do
      :nil -> :false
      _pid -> :true
    end
  end


  defp get_config(client) do
    str = Atom.to_string(client) |> String.downcase()
    config =
    cond do
      String.ends_with?(str, "webstorage") ->
        client.swift_config() |> Keyword.fetch!(:webstorage)
      String.ends_with?(str, "cloudstorage") ->
        client.swift_config() |> Keyword.fetch!(:cloudstorage)
      true ->
        raise "config not found, #{Og.context(__ENV__, :error)}"
    end
    config
  end

  # defp gen_server_name(client, config_id), do:  String.to_atom(Atom.to_string(config_id) <>  "-" <> Atom.to_string(client))
  # def ets_tablename(client, config_id), do: String.to_atom(Atom.to_string(config_id) <>  "-" <> Atom.to_string(client))


end