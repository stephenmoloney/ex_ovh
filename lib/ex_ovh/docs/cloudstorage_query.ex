defmodule ExOvh.Services.V1.Cloud.Cloudstorage.Query.Docs do
  @moduledoc :false

  @doc :false
  def moduledoc() do
    ~s"""
    Helper functions for building queries directed at the cloudstorage related parts of the `/cloud` requests.

    See `ExOvh.Services.V1.Cloud.Query` for generic cloud requests.

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

        ExOvh.Services.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.Ovh.request!()
    """
  end


end