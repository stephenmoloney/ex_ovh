defmodule ExOvh.Hubic.OpenstackApi.Auth do
  alias ExOvh.Hubic.OpenstackApi.Cache

  @methods [:get, :post, :put, :delete]
  @timeout 10_000


  ############################
  # Public
  ############################


  @spec prep_request(query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prep_request({method, uri, params} = query), do: prep_request(ExOvh, query)

  @spec prep_request(client :: atom, query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prep_request(client, query)

  def prep_request(client, {method, uri, params} = query) when method in [:get, :delete] do
    uri =  Cache.get_endpoint(client) <> uri
    if params !== :nil and params !== "", do: uri = uri <> URI.encode_query(params)
    options = %{ headers: headers(client), timeout: @timeout }
    {method, uri, options}
  end

  def prep_request(client, {method, uri, params} = query) when method in [:post, :put] do
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
