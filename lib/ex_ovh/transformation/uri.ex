defmodule ExOvh.Transformation.Uri do
  @moduledoc :false
  alias ExOvh.HttpQuery


  # Public

  @spec apply(HttpQuery.t, atom) :: HttpQuery.t
  def apply(%HttpQuery{uri: uri, completed_transformations: trans} = query, client) do
    ovh_config = client.ovh_config()
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> uri
    Map.put(query, :uri, uri)
    |> Map.put(:completed_transformations, trans ++ [:uri])
  end
  @spec apply(HttpQuery.t, map, atom) :: HttpQuery.t
  def apply(%HttpQuery{uri: uri, completed_transformations: trans} = query, query_string, client) when query_string == %{} do
    ovh_config = client.ovh_config()
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> uri
    Map.put(query, :uri, uri)
    |> Map.put(:completed_transformations, trans ++ [:uri])
  end
  def apply(%HttpQuery{uri: uri, completed_transformations: trans} = query, query_string, client) do
    ovh_config = client.ovh_config()
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> uri <> "?" <> (query_string |> URI.encode_query())
    Map.put(query, :uri, uri)
    |> Map.put(:completed_transformations, trans ++ [:uri])
  end


  @doc ~S"""
  Add the query string to a query from a map of `name`=`value` elements. Use instead of
  `ExOvh.Transformation.Uri.apply/3` when the `client` is not available but the query should
  be modified without marking it as fully `transformed` with :uri.

  To be used for GET requests.

  ## Example

      service_name="service_name"
      %ExOvh.HttpQuery{
            method: :get,
            uri: "/cdn/webstorage/#{service_name}/statistics"
            }
      |> ExOvh.Transformation.Uri.add_query_string(%{"containerName" => container_name, "region" => region

  """
  @spec add_query_string(HttpQuery.t, map) :: HttpQuery.t
  def add_query_string(%HttpQuery{} = query, qs_map) when qs_map == %{}, do: query
  def add_query_string(%HttpQuery{uri: uri} = query, qs_map) do
    uri = uri <> "?" <> URI.encode_query(qs_map)
    Map.put(query, :uri, uri)
  end


end
