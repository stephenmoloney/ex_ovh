defmodule ExOvh.Query.Ovh.Webstorage do
  @moduledoc ~S"""
  Helps to build queries for the openstack swift api.
  The raw query can be passed into a client request.

    ## Example

      ```elixir
      import ExOvh.Query.Ovh.Webstorage
      ```
  """
  alias ExOvh.Ovh.OvhApi.Cache, as: OvhApiCache



  @doc ~S"""
  GET /v1/​cdn/webstorage​, Get a list of all webstorage cdn services available for the client account

  ### Example usage

      ```elixir
      import ExOvh.Query.Ovh.Webstorage
      ExOvh.ovh_request(get_all_webstorage(), %{})
      ```
  """
  @spec get_all_webstorage() :: ExOvh.Client.raw_query_t
  def get_all_webstorage(), do: {:get, "/cdn/webstorage", :nil}



  @doc ~S"""
  GET /v1/​cdn/webstorage​/{serviceName}, Get the domain, server and storage limits for a specific webstorage cdn service

  ### Example usage

      ```elixir
      import ExOvh.Query.Ovh.Webstorage
      service_name = "cdnwebstorage-????"
      resp = ExOvh.ovh_request(get_webstorage_service(service_name), %{})
      %{
        "domain" => domain,
        "storageLimit => storage_limit,
        "server" => server
       } = resp.body
      ```
  """
  @spec get_webstorage_service(service_name :: String.t)
                               :: ExOvh.Client.raw_query_t
  def get_webstorage_service(service_name), do: {:get, "/cdn/webstorage/", service_name}



  @doc ~S"""
  GET /v1/​cdn/webstorage​/{serviceName}/serviceInfos, Get a administrative details for a specific webstorage cdn service

  ### Example usage

      ```elixir
      import ExOvh.Query.Ovh.Webstorage
      service_name = "cdnwebstorage-????"
      resp = ExOvh.ovh_request(get_webstorage_service_info(service_name), %{})
      ```
  """
  @spec get_webstorage_service_info(service_name :: String.t)
                               :: ExOvh.Client.raw_query_t
  def get_webstorage_service_info(service_name), do: {:get, "/cdn/webstorage/#{service_name}/serviceInfos", :nil}



  @doc ~S"""
  GET /v1/​cdn/webstorage​/{serviceName}/statistics, Get statistics for a specific webstorage cdn service

    `period can be "month", "week" or "day"`
    `type can be "backend", "quota" or "cdn"`

  ### Example usage

      ```elixir
      import ExOvh.Query.Ovh.Webstorage
      # service_name = "cdnwebstorage-????"
      resp = ExOvh.ovh_request(get_webstorage_service_stats(service_name, "month", "backend"), %{})
      ```
  """
  @spec get_webstorage_service_stats(service_name :: String.t, period :: String.t, type :: String.t)
                               :: ExOvh.Client.raw_query_t
  def get_webstorage_service_stats(service_name, period \\ "month", type \\ "cdn") do
    {:get, "/cdn/webstorage/#{service_name}/statistics", %{"period" => period, "type" => type} }
  end



  @doc ~S"""
  GET /v1/​cdn/webstorage​/{serviceName}/credentials, Get credentials for using the swift compliant api

  ### Example usage

      ```elixir
      import ExOvh.Query.Ovh.Webstorage
      # service_name = "cdnwebstorage-????"
      resp = ExOvh.ovh_request(get_webstorage_credentials(service_name), %{})
      ```
  """
  @spec get_webstorage_credentials(service_name :: String.t)
                               :: ExOvh.Client.raw_query_t
  def get_webstorage_credentials(service_name), do: {:get, "/cdn/webstorage/#{service_name}/credentials", :nil}




end








