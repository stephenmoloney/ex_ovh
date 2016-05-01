defmodule ExOvh.Ovh.V1.Cloud.Cloudstorage.Query do
  @moduledoc ~s"""
  Helper functions for building `queries directed at the `/cloud` part of the custom ovh api and for cloudstorage in particular.
  See `ExOvh.Ovh.V1.Cloud.Query` for generic cloud requests.


  ## Notes

  Coverage for the following ovh api requests:


      | Function | OVH API call |
      |---|---|
      | get_containers(service_name) | GET /cloud/project/{serviceName}/storage Get storage containers |
      | create_container(service_name, container_name, region \\ "SBG1") | POST /cloud/project/{serviceName}/storage Create container |
      |  |  |
      |  |  |
      |  |  |
      |  |  |
      |  |  |
      |  |  |
      |  |  |


#  GET /cloud/project/{serviceName}/storage/access Access to storage API
#  GET /cloud/project/{serviceName}/storage/{containerId} Get storage container
#  DELETE /cloud/project/{serviceName}/storage/{containerId} Delete container
#  POST /cloud/project/{serviceName}/storage/{containerId}/cors Add CORS support on your container
#  POST /cloud/project/{serviceName}/storage/{containerId}/static Deploy your container files as a static web site
#  POST /cloud/project/{serviceName}/terminate


  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.request!()
  """
  alias ExOvh.Ovh.Query


  @doc ~s"""
  GET /cloud/project/{serviceName}/storage Get storage containers

  ## Arguments

  - service_name: service name for the ovh cloud service


  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.request!()
  """
  @spec get_containers(String.t) :: Query.t
  def get_containers(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/storage",
          params: :nil
          }
  end


  @doc ~s"""
  POST /cloud/project/{serviceName}/storage Create container

  ## Arguments

  - service_name: service name for the ovh cloud service
  - container_name: name for the new container
  - region: region for the new container, defaults to "SBG1". See regions by running:
  Currently can choose from "GRA1", "BHS1", "SBG1".


  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.create_container(service_name, "test_container") |> ExOvh.request!()
  """
  @spec create_container(String.t, String.t, String.t) :: Query.t
  def create_container(service_name, container_name, region \\ "SBG1") do
    # POST /cloud/project/{serviceName}/storage Create container
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/storage",
          params: %{
                    "containerName" => container_name,
                    "region" => region
                  } |> Poison.encode!()
          }
  end



end
