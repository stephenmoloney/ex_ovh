defmodule ExOvh.Services.V1.Webstorage.Query do
  @moduledoc Module.concat(__MODULE__, Docs).moduledoc()
  alias ExOvh.Query



  @doc ~s"""
  ​Get a list of all webstorage cdn services available for the client account

  ## Api call

      GET /v1/​cdn/webstorage

  ## Example

      ExOvh.Services.V1.Webstorage.Query.get_services() |> ExOvh.Ovh.request()
  """
  @spec get_services() :: Query.t
  def get_services() do
    %Query{
          method: :get,
          uri: "/cdn/webstorage",
          params: %{}
          }
  end



  @doc ~s"""
  Get the domain, server and storage limits for a specific webstorage cdn service

  ## Api call

      GET /v1/​cdn/webstorage​/{serviceName}

  ## Arguments

  - `service_name`: Name of the Webstorage CDN service - assigned by OVH.

  ## Example

      alias ExOvh.Services.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      query = Query.get_service(service_name)
      {:ok, resp} = ExOvh.Ovh.request(query)
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
          uri: "/cdn/webstorage/#{service_name}",
          params: %{}
          }
  end



  @doc ~s"""
  Get a administrative details for a specific webstorage cdn service

  ## Api call

      GET /v1/​cdn/webstorage​/{serviceName}/serviceInfos

  ## Arguments

  - `service_name`: Name of the Webstorage CDN service - assigned by OVH.

  ## Example

      alias ExOvh.Services.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      Query.get_service_info(service_name)
      {:ok, resp} = ExOvh.Ovh.request(query)
  """
  @spec get_service_info(String.t) :: Query.t
  def get_service_info(service_name) do
    %Query{
      method: :get,
      uri: "/cdn/webstorage/#{service_name}/serviceInfos",
      params: %{}
      }
  end



  @doc ~s"""
  Get statistics for a specific webstorage cdn service

  ## Api call

      GET /v1/​cdn/webstorage​/{serviceName}/statistics

  ## Arguments

  - `service_name`: Name of the Webstorage CDN service - assigned by OVH.
  - `options`:
      - `period can be "month", "week" or "day"`
      - `type can be "backend", "quota" or "cdn"`

  ## Example

      alias ExOvh.Services.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      query = Query.get_service_stats(service_name, [period: "month", type: "backend"])
      {:ok, resp} = ExOvh.Ovh.request(query)
  """
  @spec get_service_stats(String.t, Keyword.t) :: Query.t
  def get_service_stats(service_name, opts \\ []) do
    period = Keyword.get(opts, "period", "month")
    type = Keyword.get(opts, "type", "cdn")
    %Query{
          method: :get,
          uri: "/cdn/webstorage/#{service_name}/statistics",
          params: %{
                    query_string: %{
                                    "period" => period,
                                    "type" => type
                                  }
                    }
          }
  end



  @doc ~s"""
  Get credentials for using the swift compliant api

  ## Api call

      GET /v1/​cdn/webstorage​/{serviceName}/credentials

  ## Arguments

  - `service_name`: Name of the Webstorage CDN service - assigned by OVH.

  ## Example

      alias ExOvh.Services.V1.Webstorage.Query
      service_name = "cdnwebstorage-????"
      query = Query.get_webstorage_credentials(service_name)
      {:ok, resp} = ExOvh.Ovh.request(query)
  """
  @spec get_credentials(String.t) :: ExOvh.Query.Ovh.t
  def get_credentials(service_name) do
    %Query{
          method: :get,
          uri: "/cdn/webstorage/#{service_name}/credentials",
          params: %{}
          }
  end

end
