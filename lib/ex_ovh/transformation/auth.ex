defmodule ExOvh.Transformation.Auth do
  @moduledoc :false
  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]


  # Public

  @spec apply(HTTPipe.Conn.t, atom) :: HTTPipe.Conn.t
  def apply(%HTTPipe.Conn{request: %HTTPipe.Request{method: method, headers: headers, url: url}} = conn, client) do
    trans = Map.get(conn, :completed_transformations, [])
    unless (Enum.member?(trans, :url)), do: raise ":url must be added to the transformations before applying the :auth step"
    ovh_config = client.ovh_config()
    headers = Map.merge(headers, headers([ovh_config[:application_secret], ovh_config[:application_key], ovh_config[:consumer_key], Atom.to_string(method), url, ""], client))
    request = Map.put(conn.request, :headers, headers)
    Map.put(conn, :request, request)
    |> Map.put(:completed_transformations, trans ++ [:auth])
  end


  # Private

  defp headers([app_secret, app_key, consumer_key, method, url, body] = _opts, client) do
    time = :os.system_time(:seconds) + ExOvh.Config.get_diff(client)
    headers = [
      {"X-Ovh-Application", app_key},
      {"X-Ovh-Consumer", consumer_key},
      {"X-Ovh-Timestamp", time},
      {"X-Ovh-Signature", sign_request([app_secret, consumer_key, String.upcase(method), url, body, time])}
    ]
    |> Enum.into(%{})
    Map.merge(Enum.into(@default_headers, %{}), headers)
  end

  defp sign_request([_app_secret, _consumer_key, _method, _uri, _body, _time] = opts) do
    pre_hash = Enum.join(opts, "+")
    post_hash = :crypto.hash(:sha, pre_hash) |> Base.encode16(case: :lower)
    "$1$" <> post_hash
  end


end
