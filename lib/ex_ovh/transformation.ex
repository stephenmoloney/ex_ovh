defmodule ExOvh.Transformation do
  @moduledoc :false
  alias ExOvh.{Config, HttpQuery, Query}
  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]


  # Public


  @spec prepare_request(Query.t, Keyword.t, atom) :: HttpQuery.t
  def prepare_request(%Query{method: method, uri: uri, params: params, headers: headers}, httpoison_opts, client) do
    ovh_config = client.ovh_config()
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> uri
    uri =
    cond do
      params == %{} -> uri
      Map.get(params, :query_string, :nil) != :nil -> uri <> "?" <> (Map.fetch!(params, :query_string) |> URI.encode_query())
      :true -> uri
    end
    body = if Map.has_key?(params, :binary), do: Map.get(params, :binary), else: ""
    headers = headers ++ headers([ovh_config[:application_secret], ovh_config[:application_key], ovh_config[:consumer_key], Atom.to_string(method), uri, ""], client)
    default_httpoison_opts = client.httpoison_config()
    options = merge_options(default_httpoison_opts, httpoison_opts)
    %HttpQuery{method: method, uri: uri, body: body, headers: headers, options: options, service: :ovh}
  end


  # Private


  defp headers([app_secret, app_key, consumer_key, method, uri, body] = _opts, client) do
    time = :os.system_time(:seconds) + Config.get_diff(client)
    headers = [
                {"X-Ovh-Application", app_key},
                {"X-Ovh-Consumer", consumer_key},
                {"X-Ovh-Timestamp", time},
                {"X-Ovh-Signature", sign_request([app_secret, consumer_key, String.upcase(method), uri, body, time])}
              ]
              |> Enum.into(%{})
    Map.merge(Enum.into(@default_headers, %{}), headers) |> Enum.into([])
  end


  defp sign_request([_app_secret, _consumer_key, _method, _uri, _body, _time] = opts) do
    pre_hash = Enum.join(opts, "+")
    post_hash = :crypto.hash(:sha, pre_hash) |> Base.encode16(case: :lower)
    "$1$" <> post_hash
  end

  defp merge_options(opts1, opts2) do
    opts1 = Enum.into(opts1, %{})
    opts2 = Enum.into(opts2, %{})
    opts = Map.merge(opts1, opts2)
    Enum.into(opts, [])
  end


end
