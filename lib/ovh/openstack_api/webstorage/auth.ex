defmodule ExOvh.Ovh.Openstack.Webstorage.Auth do
  alias ExOvh.Ovh.OvhApi.Cache, as: ClientCache
  alias ExOvh.Ovh.Openstack.Webstorage.Cache, as: OpenCache
  import ExOvh.Query.Ovh.Webstorage

  @methods [:get, :post, :put, :delete]
  @timeout 10_000


  ############################
  # Public
  ############################


  @spec prepare_request(client :: atom, query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prepare_request(client, query)

  def prepare_request(client, {method, uri, params} = query) when method in [:get, :delete] do
    uri =  OpenCache.get_endpoint(client) <> uri
    if params !== :nil and params !== "", do: uri = uri <> "?" <> URI.encode_query(params)
    options = %{ headers: headers(client), timeout: @timeout }
    {method, uri, options}
  end

  def prepare_request(client, {method, uri, params} = query) when method in [:post, :put] do
    uri =  OpenCache.get_endpoint(client) <> uri
    if params !== "" and params !== :nil and is_map(params), do: params = Poison.encode!(params)
    options = %{ body: params, headers: headers(client), timeout: @timeout }
    {method, uri, options}
  end


  ############################
  # Private
  ############################


  defp headers(client), do: %{ "X-Auth-Token": Cache.get_credentials_token(client) }

  defp config(), do: ClientCache.get_config(ExOvh)
  defp config(client), do: ClientCache.get_config(client)


end
