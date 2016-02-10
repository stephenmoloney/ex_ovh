defmodule ExOvh.Hubic.OpenstackApi.Auth do
  alias ExOvh.Hubic.OpenstackApi.Cache

  @methods [:get, :post, :put, :delete]
  @timeout 10_000


  ############################
  # Public
  ############################


  @spec prepare_request(query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prepare_request({method, uri, params} = query), do: prepare_request(ExOvh, query)

  @spec prepare_request(client :: atom, query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prepare_request(client, query)

  def prepare_request(client, {method, uri, params} = query) when method in [:get, :delete] do
    uri =  Cache.get_endpoint(client) <> uri
    if params !== :nil and params !== "", do: uri = uri <> URI.encode_query(params)
    options = %{ headers: headers(client), timeout: @timeout }
    {method, uri, options}
  end

  def prepare_request(client, {method, uri, params} = query) when method in [:post, :put] do
    uri =  Cache.get_endpoint(client) <> uri
    if params !== "" and params !== :nil and method in [:post, :put], do: params = Poison.encode!(params)
    options = %{ body: params, headers: headers(client), timeout: @timeout }
    {method, uri, options}
  end



  ############################
  # Private
  ############################


  defp headers(client), do: %{ "X-Auth-Token": Cache.get_credentials_token(client) }


end
