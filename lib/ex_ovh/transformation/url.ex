defmodule ExOvh.Transformation.Url do
  @moduledoc :false


  # Public

  @spec apply(HTTPipe.Conn.t, atom) :: HTTPipe.Conn.t
  def apply(%HTTPipe.Conn{request: %HTTPipe.Request{url: url}} = conn, client) do
    ovh_config = client.ovh_config()
    trans = Map.get(conn, :completed_transformations, [])
    url = ovh_config[:endpoint] <> ovh_config[:api_version] <> url
    request = Map.put(conn.request, :url, url)
    Map.put(conn, :request, request)
    |> Map.put(:completed_transformations, trans ++ [:url])
  end
  @spec apply(HTTPipe.Conn.t, map, atom) :: HTTPipe.Conn.t
  def apply(%HTTPipe.Conn{request: %HTTPipe.Request{url: url}} = conn, query_string_map, client) when query_string_map == %{} do
    apply(conn, client)
  end
  def apply(%HTTPipe.Conn{request: %HTTPipe.Request{url: url}} = conn, query_string_map, client) do
    ovh_config = client.ovh_config()
    trans = Map.get(conn, :completed_transformations, [])
    url = ovh_config[:endpoint] <> ovh_config[:api_version] <> url
    request = Map.put(conn.request, :url, url)
    |> add_query_string(query_string_map)
    Map.put(conn, :request, request)
    |> Map.put(:completed_transformations, trans ++ [:url])
  end


  @doc ~S"""
  Add the request string to a request from a map of `name`=`value` elements. Use instead of
  `ExOvh.Transformation.Url.apply/3` when the `client` is not available but the request should
  be modified without marking it as fully `transformed` with :url.

  To be used for GET requests.

  ## Example

      service_name="service_name"
      %HTTPipe.Request{
        method: :get,
        url: "/cdn/webstorage/#{service_name}/statistics"
      }
      |> ExOvh.Transformation.Url.add_query_string(%{"containerName" => container_name, "region" => region})
      |> ExOvh.Request!()

  """
  @spec add_query_string(HTTPipe.Request.t, map) :: HTTPipe.Request.t
  def add_query_string(%HTTPipe.Request{} = request, qs_map) when qs_map == %{}, do: request
  def add_query_string(%HTTPipe.Request{url: url} = request, qs_map) do
    url = url <> "?" <> URI.encode_query(qs_map)
    Map.put(request, :url, url)
  end


end
