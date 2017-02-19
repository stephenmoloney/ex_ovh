defmodule ExOvh.Transformation.Auth do
  @moduledoc :false
  alias ExOvh.{Config, HttpQuery}
  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]


  # Public

  @spec apply(HttpQuery.t, atom) :: HttpQuery.t
  def apply(%HttpQuery{method: method, headers: headers, uri: uri, completed_transformations: trans} = query, client) do
    ovh_config = client.ovh_config()
    headers = headers ++ headers([ovh_config[:application_secret], ovh_config[:application_key], ovh_config[:consumer_key], Atom.to_string(method), uri, ""], client)
    Map.put(query, :headers, headers)
    |> Map.put(:completed_transformations, trans ++ [:auth])
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


end
