defimpl Openstex.Auth, for: Openstex.Openstack.Swift.Query do
  @moduledoc :false
  alias Openstex.Openstack.Swift.Query
  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]


  # Public


  @spec prepare_request(Query.t, Keyword.t, atom) :: Openstex.HttpQuery.t
  def prepare_request(query, httpoison_opts, client)

  def prepare_request(%Query{method: method, uri: uri, params: params}, httpoison_opts, client)
                                  when method in [:get, :head, :delete] do
    cache = client.cache()
    uri = cache.get_swift_endpoint(client) <> uri
    body = ""
    headers =  headers(client)
    default_httpoison_opts = client.httpoison_config()
    options = Keyword.merge(default_httpoison_opts, httpoison_opts)
    if params !== :nil and params !== "", do: uri = uri <> "?" <> URI.encode_query(params)
    %Openstex.HttpQuery{method: method, uri: uri, body: body, headers: headers, options: options, service: :openstack}
  end

  def prepare_request(%Query{method: method, uri: uri, params: params}, httpoison_opts, client)
                                  when method in [:post, :put] do
    cache = client.cache()
    uri = cache.get_swift_endpoint(client) <> uri
    headers =  headers(client)
    default_httpoison_opts = client.httpoison_config()
    options = Keyword.merge(default_httpoison_opts, httpoison_opts)
    if params !== "" and params !== :nil and is_map(params), do: params = Poison.encode!(params)
    body = params || ""
    %Openstex.HttpQuery{method: method, uri: uri, body: body, headers: headers, options: options, service: :openstack}
  end


  # Private


  defp headers(client) do
    @default_headers ++
    [
      {
        "X-Auth-Token", client.cache().get_xauth_token(client)
      }
    ]
  end


end
