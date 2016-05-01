defmodule ExOvh.Auth.Openstack.Swift.Cache.Webstorage do
  @moduledoc :false
  alias Openstex.Helpers.V2.Keystone.Identity
  defstruct [ :domain, :storage_limit, :server, :endpoint, :username, :password, :tenant_name ]
  @type t :: %__MODULE__{domain: String.t, storage_limit: String.t, server: String.t, endpoint: String.t,
                         username: String.t, password: String.t, tenant_name: String.t}
  use ExConstructor


  @doc :false
  @spec webstorage(atom, String.t) :: __MODULE__.t | no_return
  def webstorage(client, config) do
    cdn_name = Keyword.fetch!(config, :cdn_name)
    properties = ExOvh.Ovh.V1.Webstorage.Query.get_service(cdn_name) |> client.request!() |> Map.fetch!(:body)
    credentials = ExOvh.Ovh.V1.Webstorage.Query.get_credentials(cdn_name) |> client.request!() |> Map.fetch!(:body)

    webstorage =
    %{
      "domain" => domain,
      "storageLimit" => storage_limit,
      "server" => server,
      "endpoint" => endpoint,
      "login" => username,
      "password" => password,
      "tenant" => tenant_name
    } = Map.merge(properties, credentials)
    webstorage = webstorage
    |> Map.delete("tenant") |> Map.delete("login")
    |> Map.put("username", username) |> Map.put("tenantName", tenant_name)
    webstorage = __MODULE__.new(webstorage)
  end

  @doc :false
  @spec create_identity(atom, atom) :: Identity.t | no_return
  def create_identity(client, config_id) do
    config = client.swift_config() |> Keyword.fetch!(config_id)
    cdn_name = Keyword.fetch!(config, :cdn_name)
    webstorage = webstorage(client, cdn_name)
    %{endpoint: endpoint, username: username, password: password, tenant_name: tenant_name} = webstorage
    identity = Module.concat(client, Helpers.Keystone).authenticate!(endpoint, username, password, [tenant_name: tenant_name])
  end

#  token = Openstex.Keystone.V2.Query.get_token(endpoint, username, password)
#  |> Og.log_return(:warn)
#  |> client.request!()
#  |> Og.log_return(:warn)
#  |> Map.get(:body)
#  |> Map.get("access")
#  |> Map.get("token")
#  |> Map.get("id")
#  # |> Map.get("body")["access"]["token"]["id"]
#  # |> Map.get(:body)  |> Og.log_return(:debug) |> Map.get("access") |> Og.log_return(:debug) |> Map.get("token") |> Og.log_return(:debug) |> Map.get("id")
#
#  {token, endpoint, tenant} |> Og.log()
#  identity = Openstex.Keystone.V2.Query.get_identity(token, endpoint, tenant)
#  |> Og.log_return(:debug)
#  |> client.request!()
#  |> Og.log_return(:debug)
#  |> Keystone.parse_nested_map_into_identity_struct()

end