defimpl Openstex.Auth, for: ExOvh.Ovh.Query do
  @moduledoc :false

  alias ExOvh.Utils
  alias ExOvh.Ovh.Query
  alias ExOvh.Auth.Ovh.Cache
  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]


  # Public


  @spec prepare_request(Query.t, Keyword.t, atom) :: Openstex.HttpQuery.t
  def prepare_request(query, opts, client)

  def prepare_request(%Query{method: method, uri: uri, params: params}, opts, client) when method in [:get, :head, :delete] do
    config = Utils.config(client)
    if params !== :nil and params !== "" and is_map(params), do: uri = uri <> "?" <> URI.encode_query(params)
    if params !== :nil and params !== "" and is_map(params) === :false, do: uri = uri <> URI.encode_www_form(params)
    uri = Utils.uri(uri, config)
    body = params || ""
    headers = headers([Utils.app_secret(config), Utils.app_key(config), Utils.get_consumer_key(config), Atom.to_string(method), uri, ""], client)
    options = Utils.set_opts(opts, config)
    %Openstex.HttpQuery{method: method, uri: uri, body: body, headers: headers, options: options, service: :ovh}
  end

  def prepare_request(%Query{method: method, uri: uri, params: params}, opts, client) when method in [:post, :put] do
    config = Utils.config(client)
    if params !== "" and params !== :nil and is_map(params), do: params = Poison.encode!(params)
    uri = Utils.uri(uri, config)
    body = params || ""
    header_opts = [Utils.app_secret(config), Utils.app_key(config), Utils.get_consumer_key(config), Atom.to_string(method), uri, params]
    headers = headers([Utils.app_secret(config), Utils.app_key(config), Utils.get_consumer_key(config), Atom.to_string(method), uri, ""], client)
    options = Utils.set_opts(opts, config)
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
