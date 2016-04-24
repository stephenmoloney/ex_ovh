defmodule ExOvh.Ovh.V1.Webstorage.Query do
  @moduledoc ~s"""
  Helper functions for building `queries directed at the `/cdn/webstorage` part of the custom ovh api.

  ## Example

      alias ExOvh.Ovh.V1.Webstorage.Query
      query = Query.get_all_webstorage()
      ExOvh.request(query)
  """
  alias ExOvh.Ovh.Query



  @doc ~s"""
  GET /v1/​cdn/webstorage​, Get a list of all webstorage cdn services available for the client account

  ### Example usage

      alias ExOvh.Ovh.V1.Webstorage.Query
      query = Query.get_services()
      ExOvh.request(query)
  """
  @spec get_services() :: Query.t
  def get_services() do
    %Query{
          method: :get,
          uri: "/cdn/webstorage",
          params: :nil
          }
  end



  @doc ~s"""
  GET /v1/​cdn/webstorage​/{serviceName}, Get the domain, server and storage limits for a specific webstorage cdn service

  ### Example usage

      alias ExOvh.Ovh.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      query = Query.get_service(service_name)
      {:ok, resp} = ExOvh.request(query)
      %{
        "domain" => domain,
        "storageLimit => storage_limit,
        "server" => server
       } = resp.body
  """
  @spec get_service(String.t) :: Query.t
  def get_service(service_name) do
   %Query{
          method: :get,
          uri: "/cdn/webstorage/",
          params: service_name
          }
  end



  @doc ~s"""
  GET /v1/​cdn/webstorage​/{serviceName}/serviceInfos, Get a administrative details for a specific webstorage cdn service

  ### Example usage

      alias ExOvh.Ovh.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      Query.get_service_info(service_name)
      {:ok, resp} = ExOvh.request(query)
  """
  @spec get_service_info(String.t) :: Query.t
  def get_service_info(service_name) do
    %Query{
      method: :get,
      uri: "/cdn/webstorage/#{service_name}/serviceInfos",
      params: :nil
      }
  end



  @doc ~s"""
  GET /v1/​cdn/webstorage​/{serviceName}/statistics, Get statistics for a specific webstorage cdn service

    `period can be "month", "week" or "day"`
    `type can be "backend", "quota" or "cdn"`

  ### Example usage

      alias ExOvh.Ovh.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      query = Query.get_service_stats(service_name, [period: "month", type: "backend"])
      {:ok, resp} = ExOvh.request(query)
  """
  @spec get_service_stats(String.t, Keyword.t) :: Query.t
  def get_service_stats(service_name, opts \\ []) do
    period = Keyword.get(opts, "period", "month")
    type = Keyword.get(opts, "type", "cdn")
    %Query{
          method: :get,
          uri: "/cdn/webstorage/#{service_name}/statistics",
          params: %{"period" => period, "type" => type}
          }
  end



  @doc ~s"""
  GET /v1/​cdn/webstorage​/{serviceName}/credentials, Get credentials for using the swift compliant api

  ### Example usage

      alias ExOvh.Ovh.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      query = Query.get_webstorage_credentials(service_name)
      {:ok, resp} = ExOvh.request(query)
  """
  @spec get_credentials(String.t) :: ExOvh.Query.Ovh.t
  def get_credentials(service_name) do
    %Query{
          method: :get,
          uri: "/cdn/webstorage/#{service_name}/credentials",
          params: :nil
          }
  end

end
