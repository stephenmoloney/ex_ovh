defmodule ExOvh.Auth.Openstack.Swift.Cache.Webstorage do
  @moduledoc :false
  alias Openstex.Keystone.V2.Helpers, as: Keystone
  alias Openstex.Keystone.V2.Helpers.Identity
  defstruct [ :domain, :storage_limit, :server, :endpoint, :username, :password, :tenant_name ]
  @type t :: %__MODULE__{domain: String.t, storage_limit: String.t, server: String.t, endpoint: String.t,
                         username: String.t, password: String.t, tenant_name: String.t}
  use ExConstructor


  @doc :false
  @spec webstorage({atom, atom}, String.t) :: __MODULE__.t | no_return
  def webstorage(ovh_client, cdn_name) do
    Og.context(__ENV__, :debug)

    properties = ExOvh.Ovh.V1.Webstorage.Query.get_service(cdn_name) |> ovh_client.request!() |> Map.fetch!(:body)
    credentials = ExOvh.Ovh.V1.Webstorage.Query.get_credentials(cdn_name) |> ovh_client.request!() |> Map.fetch!(:body)

    webstorage =
    %{
      "domain" => _domain,
      "storageLimit" => _storage_limit,
      "server" => _server,
      "endpoint" => _endpoint,
      "login" => username,
      "password" => _password,
      "tenant" => tenant_name
    } = Map.merge(properties, credentials)
    webstorage = webstorage
    |> Map.delete("tenant") |> Map.delete("login")
    |> Map.put("username", username) |> Map.put("tenantName", tenant_name)
    __MODULE__.new(webstorage)
  end


  @doc :false
  @spec create_identity({atom, atom}, Keyword.t) :: Identity.t | no_return
  def create_identity({ovh_client, _swift_client}, config) do
    Og.context(__ENV__, :debug)

    cdn_name = Keyword.fetch!(config, :cdn_name)
    webstorage = webstorage(ovh_client, cdn_name)
    %{endpoint: endpoint, username: username, password: password, tenant_name: tenant_name} = webstorage
    Keystone.authenticate!(endpoint, username, password, [tenant_name: tenant_name])
  end


end