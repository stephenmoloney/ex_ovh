defmodule ExOvh.Ovh.V1.Cloud.Cloudstorage.Query do
  @moduledoc ~s"""
  Helper functions for building queries directed at the cloudstorage related parts of the `/cloud` requests.

  See `ExOvh.Ovh.V1.Cloud.Query` for generic cloud requests.

  ## Functions Summary

  | Function | Description | OVH API call |
  |---|---|---|
  | `get_containers/1` | <small>Get containers for a given swift tenant id (project id or ovh service name)</small> | <sub><sup>GET /cloud/project/{serviceName}/storage </sup></sub> |
  | `create_container/3` | <small>Create a container for a given tenant_id (ovh service_name), a container and a region.</small> | <sub><sup>POST /cloud/project/{serviceName}/storage</sup></sub> |
  | `get_access/1` | <small>Get access details for the Swift API for a given swift tenant_id (ovh service_name)</small> | <sub><sup>GET /cloud/project/{serviceName}/storage/access</sup></sub> |
  | `container_info/2` | <small>Gets details about a container such as objects, size, region, public or not, static_url, name, ...</small> | <sub><sup>GET /cloud/project/{serviceName}/storage/{containerId}</sup></sub> |
  | `delete_container/2` | <small>Deletes a given container.</small> | <sub><sup>DELETE /cloud/project/{serviceName}/storage/{containerId}</sup></sub> |
  | `modify_container_cors/3` | <small>Modify the CORS settings for a container. See [swift docs](http://docs.openstack.org/developer/swift/cors.html)</small> | <sub><sup>POST /cloud/project/{serviceName}/storage/{containerId}/cors Add CORS support on your container</sup></sub> |
  | `deploy_container_as_static_website/2` | <small>Deploy the container files as a static web site.</small> | <sub><sup>POST /cloud/project/{serviceName}/storage/{containerId}/static</sup></sub> |


  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.Ovh.request!()
  """
  alias ExOvh.Ovh.Query


  @doc ~s"""
  Get storage containers

  ## Api call

      GET /cloud/project/{serviceName}/storage

  ## Arguments

  - `service_name`: service name for the ovh cloud service

  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.Ovh.request!()
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
  Create container

  ## Api call

      POST /cloud/project/{serviceName}/storage

  ## Arguments

  - `service_name`: service name for the ovh cloud service
  - `container_name`: name for the new container
  - `region`: region for the new container, defaults to "SBG1". See regions by running:
  Currently can choose from "GRA1", "BHS1", "SBG1".


  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.create_container(service_name, "test_container") |> ExOvh.Ovh.request!()
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


  @doc ~s"""
  Gets the x_auth_token and the swift endpoints for a given tenant_id (ovh service_name). A different endpoint is returned
  depending on the region. Examples of regions include "BHS1", "SBG1", "GRA1". With these details, requests can be made through
  the Swift api.

  ## Api call

      GET /cloud/project/{serviceName}/storage/access

  ## Arguments

  - `service_name`: service name for the ovh cloud service

  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.get_access(service_name) |> ExOvh.Ovh.request!()
  """
  @spec get_access(String.t) :: Query.t
  def get_access(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/storage/access",
          params: :nil
          }
  end



  @doc ~s"""
  Gets the details for a given container.

  Returns information such as a list of objects in the container, size of the container, whether the container is public
  or not, the region of the container, the name of the container, the number of stored objects for the container and the
  static url for the container.

  ## Api call

      GET /cloud/project/{serviceName}/storage/{containerId}

  ## Arguments

  - `service_name`: service name for the ovh cloud service
  - `container_id`: container_id for a given container. *Note*: this is not the same as the container_name.

  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.container_info(service_name, container_id) |> ExOvh.Ovh.request!()
  """
  @spec container_info(String.t, String.t) :: Query.t
  def container_info(service_name, container_id) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/storage/#{container_id}",
          params: :nil
          }
  end


  @doc ~s"""
  Deletes a given container.

  *Note:* container_d is not the same as container_name.

  ## Api call

      DELETE /cloud/project/{serviceName}/storage/{containerId}

  ## Arguments

  - `service_name`: service name for the ovh cloud service
  - `container_id`: container_id for a given container. *Note*: this is not the same as the container_name.

  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.delete_container(service_name, container_id) |> ExOvh.Ovh.request!()
  """
  @spec delete_container(String.t, String.t) :: Query.t
  def delete_container(service_name, container_id) do
    %Query{
          method: :delete,
          uri: "/cloud/project/#{service_name}/storage/#{container_id}",
          params: :nil
          }
  end


  @doc ~s"""
  Modify CORS settings for a container.

  Modifies the container metadata such that cross origin requests can be permitted.
  See [CORS section of swift docs](http://docs.openstack.org/developer/swift/cors.html) for more info. Ans see here for more
  on [CORS in general](http://enable-cors.org/resources.html)

  | Metadata |	Use |
  | --- |	--- |
  | X-Container-Meta-Access-Control-Allow-Origin | Origins to be allowed to make Cross Origin Requests, space separated. |


  *Note:* container_d is not the same as container_name.

  ## Api call

      DELETE /cloud/project/{serviceName}/storage/{containerId}

  ## Arguments

  - `service_name`: service name for the ovh cloud service
  - `container_id`: container_id for a given container. *Note*: this is not the same as the container_name.
  - `origin`: an origin that may make cross origin requests to the container. Defaults to `{}` (none) if left absent.

  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.modify_container_cors(service_name, container_id, "http://localhost:4001/") |> ExOvh.Ovh.prepare_request() |> Og.log_return() |> ExOvh.Ovh.request!()

  ## Notes

  To get a full overview of the container details with all metadata, the Swift client should be used. To see the changes, try running the following
  command for the `container_name` associated with this `container_id`. In fact, the OVH functions are not really required, most changes can be made directly
  using queries sent via the `Swift.Cloudstorage` client.

      account = ExOvh.Swift.Cloudstorage.account()
      container = "test_container"
      Openstex.Swift.V1.Query.container_info(container, account) |> ExOvh.Swift.Cloudstorage.request!() |> Map.get(:headers) |> Map.get("X-Container-Meta-Access-Control-Allow-Origin")
  """
  @spec modify_container_cors(String.t, String.t, String.t) :: Query.t
  def modify_container_cors(service_name, container_id, origin \\ {}) do
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/storage/#{container_id}/cors",
          params: %{
                  "origin" => origin
                  }  |> Poison.encode!()
          }
  end



  @doc ~s"""
  Deploy a container as a static website.

  Modifies the ACL settings for a container on the "X-Container-Read" header and also other container metadata.
  See [swift auth docs](http://docs.openstack.org/developer/swift/overview_auth.html),
  [swift acl middleware](http://docs.openstack.org/developer/swift/misc.html#module-swift.common.middleware.acl)
  and [swift account middleware](http://docs.openstack.org/developer/swift/middleware.html#module-swift.common.middleware.tempauth)
  for more information.

  ## Api call

      POST /cloud/project/{serviceName}/storage/{containerId}/static

  ## Arguments

  - `service_name`: service name for the ovh cloud service
  - `container_id`: container_id for a given container. *Note*: this is not the same as the container_name.

  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.modify_container_cors(service_name, container_id, "http://localhost:4001/") |> ExOvh.Ovh.prepare_request() |> Og.log_return() |> ExOvh.Ovh.request!()

  ## Notes

  To get a full overview of the container details with all metadata, the Swift client should be used. To see the changes, try running the following
  command for the `container_name` associated with this `container_id`. In fact, the OVH functions are not really required, most changes can be made directly
  using queries sent via the `Swift.Cloudstorage` client.

      account = ExOvh.Swift.Cloudstorage.account()
      container = "test_container"
      Openstex.Swift.V1.Query.container_info(container, account) |> ExOvh.Swift.Cloudstorage.request!() |> Map.get(:headers)
  """
  @spec deploy_container_as_static_website(String.t, String.t) :: Query.t
  def deploy_container_as_static_website(service_name, container_id) do
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/storage/#{container_id}/static",
          params: :nil
          }
  end



end
