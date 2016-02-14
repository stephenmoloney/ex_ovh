defmodule ExOvh.Ovh.OpenstackApi.Webstorage.Auth do
  @moduledoc :false
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Cache, as: WebStorageCache

  @methods [:get, :post, :put, :delete]
  @timeout 10_000


  ############################
  # Public
  ############################


  @spec prepare_request(client :: atom, query :: ExOvh.Client.raw_query_t, service :: String.t)
                     :: ExOvh.Client.query_t
  def prepare_request(client, query)

  def prepare_request(client, {method, uri, params} = query, service) when method in [:get, :delete] do
    uri =  WebStorageCache.get_swift_endpoint(client, service) <> uri
    if params !== :nil and params !== "", do: uri = uri <> "?" <> URI.encode_query(params)
    options = %{ headers: headers(client, service), timeout: @timeout }
    {method, uri, options}
    |> LoggingUtils.log_return(:debug)
  end

  def prepare_request(client, {method, uri, params} = query, service) when method in [:post, :put] do
    uri =  WebStorageCache.get_swift_endpoint(client, service) <> uri
    if params !== "" and params !== :nil and is_map(params), do: params = Poison.encode!(params)
    options = %{ body: params, headers: headers(client, service), timeout: @timeout }
    {method, uri, options}
    |> LoggingUtils.log_return(:debug)
  end


  ############################
  # Private
  ############################


  defp headers(client, service) do
    %{
      "Content-Type": "application/json; charset=utf-8",
      "X-Auth-Token": WebStorageCache.get_credentials_token(client, service)
     }
  end


end
