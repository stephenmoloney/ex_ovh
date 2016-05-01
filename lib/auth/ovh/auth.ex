defimpl Openstex.Auth, for: ExOvh.Ovh.Query do
  @moduledoc :false

  alias ExOvh.Utils
  alias ExOvh.Ovh.Query
  alias ExOvh.Auth.Ovh.Cache
  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]


  # Public


  @spec prepare_request(Query.t, Keyword.t, atom) :: Openstex.HttpQuery.t
  def prepare_request(query, httpoison_opts, client)

  def prepare_request(%Query{method: method, uri: uri, params: params}, httpoison_opts, client) when method in [:get, :head, :delete] do
    uri = if params !== :nil and params !== "" and is_map(params), do: uri <> "?" <> URI.encode_query(params), else: uri
    uri = if params !== :nil and params !== "" and is_map(params) === :false, do: uri <> URI.encode_www_form(params), else: uri
    ovh_config = client.config()
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> uri
    body = params || ""
    headers = headers([ovh_config[:application_secret], ovh_config[:application_key], ovh_config[:consumer_key], Atom.to_string(method), uri, ""], client)
    default_httpoison_opts = client.httpoison_config()
    options = Keyword.merge(default_httpoison_opts, httpoison_opts)
    %Openstex.HttpQuery{method: method, uri: uri, body: body, headers: headers, options: options, service: :ovh}
  end

  def prepare_request(%Query{method: method, uri: uri, params: params}, httpoison_opts, client) when method in [:post, :put] do
    if params !== "" and params !== :nil and is_map(params), do: params = Poison.encode!(params)
    ovh_config = client.config()
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> uri
    body = params || ""
    headers = headers([ovh_config[:application_secret], ovh_config[:application_key], ovh_config[:consumer_key], Atom.to_string(method), uri, ""], client)
    default_httpoison_opts = client.httpoison_config()
    options = Keyword.merge(default_httpoison_opts, httpoison_opts)
    %Openstex.HttpQuery{method: method, uri: uri, body: body, headers: headers, options: options, service: :ovh}
  end


  # Private


  defp headers([app_secret, app_key, consumer_key, method, uri, body] = opts, client) do
    time = :os.system_time(:seconds) + Cache.get_time_diff(client)
    headers = [
                {"X-Ovh-Application", app_key},
                {"X-Ovh-Consumer", consumer_key},
                {"X-Ovh-Timestamp", time},
                {"X-Ovh-Signature", sign_request([app_secret, consumer_key, String.upcase(method), uri, body, time])}
              ]
              |> Enum.into(%{})
    Map.merge(Enum.into(@default_headers, %{}), headers) |> Enum.into([])
  end


  defp sign_request([app_secret, consumer_key, method, uri, body, time] = opts) do
    pre_hash = Enum.join(opts, "+")
    post_hash = :crypto.hash(:sha, pre_hash) |> Base.encode16(case: :lower)
    "$1$" <> post_hash
  end


end
