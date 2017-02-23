defmodule ExOvh.V1.Cloud do
  @moduledoc ~s"""
  Helper functions for building queries directed at the cloudstorage related parts of the `/cloud` part of the [OVH API](https://api.ovh.com/console/).

  See `ExOvh.V1.Cloud` for generic cloud requests.

  ## Functions Summary

  | Function | Description | OVH API call |
  |---|---|---|
  | `list_services/0` | <small>List available services or list available cloud projects. A returned project id in OVH terms is similar to a tenant id in swift terms</small> | <sub><sup>GET /cloud/project</sup></sub> |
  | `get_users/1` | <small>Get all users</small> | <sub><sup>GET /cloud/project/{serviceName}/user</sup></sub> |
  | `create_user/2` | <small>Create user</small> | <sub><sup>POST /ctsloud/project/{serviceName}/user</sup></sub> |
  | `get_user_details/2` | <small>Get user details. Returns the user_id and username and other details.</small> | <sub><sup>GET /cloud/project/{serviceName}/user/{userId}</sup></sub> |
  | `delete_user/2` | <small>Delete user</small> | <sub><sup>DELETE /cloud/project/{serviceName}/user/{userId}</sup></sub> |
  | `download_openrc_script/3` | <small>Get RC file of OpenStack</small> | <sub><sup>GET /cloud/project/{serviceName}/user/{userId}/openrc</sup></sub> |
  | `regenerate_credentials/2`  | <small>Regenerate user credentials including password</small> | <sub><sup>POST /cloud/project/{serviceName}/user/{userId}/regeneratePassword</sup></sub> |
  | `swift_identity/3` | <small>Gets a json object similar to that returned by Keystone Identity. Includes the 'X-Auth-Token'</small> | <sub><sup>POST /cloud/project/{serviceName}/user/{userId}/token</sup></sub> |
  | `create_project/2` | <small>Start a new cloud project in the OVH cloud. Corresponds to creating a new Swift stack with a new tenant_id.</small> | <sub><sup>POST /cloud/createProject</sup></sub> |
  | `get_prices/2` | <small>Get Prices for OVH cloud services.</small> | <sub><sup>GET /cloud/price</sup></sub> |
  | `project_info/1` | <small>Get information about a project with the project_id (tenant_id)</small> | <sub><sup>GET /cloud/project/{serviceName}</sup></sub> |
  | `modify_project/2` | <small>Modify a project properties. Change the project description.</small> | <sub><sup>PUT /cloud/project/{serviceName}</sup></sub> |
  | `project_administrative_info/1` | <small>Get administration information about the project.</small> | <sub><sup>GET /cloud/project/{serviceName}/serviceInfos</sup></sub> |
  | `project_quotas/1` | <small>Get project quotas.</small> | <sub><sup>GET /cloud/project/{serviceName}/quota</sup></sub> |
  | `project_regions/1` | <small>Get project regions.</small> | <sub><sup>GET /cloud/project/{serviceName}/region</sup></sub> |
  | `project_region_info/2` | <small>Get details about a project region.</small> | <sub><sup>GET /cloud/project/{serviceName}/region/{regionName}</sup></sub> |
  | `project_consumption/3` | <small>Get details about a project consumption for a given `date_from` and `date_to`.</small> | <sub><sup>GET /cloud/project/{serviceName}/consumption</sup></sub> |
  | `project_bills/3` | <small>Get details about a project billing for a given `date_from` and `date_to`..</small> | <sub><sup>GET /cloud/project/{serviceName}/bill</sup></sub> |
  | `create_project_alert/4` | <small>Add a new project alert</small> | <sub><sup>POST /cloud/project/{serviceName}/alerting</sup></sub> |
  | `get_project_alert_info/2` | <small>Get detailed information about a project alert.</small> | <sub><sup>GET /cloud/project/{serviceName}/alerting/{id}</sup></sub> |
  | `modify_project_alert/5` | <small>Modify an existing project alert.</small> | <sub><sup>PUT /cloud/project/{serviceName}/alerting/{id}</sup></sub> |
  | `delete_project_alert/2` | <small>Delete an existing project alert.</small> | <sub><sup>DELETE /cloud/project/{serviceName}/alerting/{id}</sup></sub> |
  | `terminate_service/2` | <small>Terminate a cloud project.</small> | <sub><sup>POST /cloud/project/{serviceName}/terminate</sup></sub> |
  | `get_containers/1` | <small>Get containers for a given swift tenant id (project id or ovh service name)</small> | <sub><sup>GET /cloud/project/{serviceName}/storage </sup></sub> |
  | `create_container/3` | <small>Create a container for a given tenant_id (ovh service_name), a container and a region.</small> | <sub><sup>POST /cloud/project/{serviceName}/storage</sup></sub> |
  | `get_access/1` | <small>Get access details for the Swift API for a given swift tenant_id (ovh service_name)</small> | <sub><sup>GET /cloud/project/{serviceName}/storage/access</sup></sub> |
  | `container_info/2` | <small>Gets details about a container such as objects, size, region, public or not, static_url, name, ...</small> | <sub><sup>GET /cloud/project/{serviceName}/storage/{containerId}</sup></sub> |
  | `delete_container/2` | <small>Deletes a given container.</small> | <sub><sup>DELETE /cloud/project/{serviceName}/storage/{containerId}</sup></sub> |
  | `modify_container_cors/3` | <small>Modify the CORS settings for a container. See [swift docs](http://docs.openstack.org/developer/swift/cors.html)</small> | <sub><sup>POST /cloud/project/{serviceName}/storage/{containerId}/cors Add CORS support on your container</sup></sub> |
  | `deploy_container_as_static_website/2` | <small>Deploy the container files as a static web site.</small> | <sub><sup>POST /cloud/project/{serviceName}/storage/{containerId}/static</sup></sub> |

  ## Notes

  - `service_name` or `serviceName` corresponds to the Openstack `tenant_id`

  ## Example

      ExOvh.V1.Cloud.get_containers(service_name) |> ExOvh.request!()
  """
  alias ExOvh.Transformation.{Body, Url}


  @doc ~s"""
  Get storage containers

  ## Api call

      GET /cloud/project/{serviceName}/storage

  ## Arguments

  - `service_name`: service name for the ovh cloud service

  ## Example

      ExOvh.V1.Cloud.get_containers(service_name) |> ExOvh.request!()
  """
  @spec get_containers(String.t) :: HTTPipe.Conn.t
  def get_containers(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/storage",
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
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

      ExOvh.V1.Cloud.create_container(service_name, "test_container") |> ExOvh.request!()
  """
  @spec create_container(String.t, String.t, String.t) :: HTTPipe.Conn.t
  def create_container(service_name, container_name, region \\ "SBG1") do
    # POST /cloud/project/{serviceName}/storage Create container
    body =
    %{
      "containerName" => container_name,
      "region" => region
     }
    |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/storage"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
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

      ExOvh.V1.Cloud.get_access(service_name) |> ExOvh.request!()
  """
  @spec get_access(String.t) :: HTTPipe.Conn.t
  def get_access(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/storage/access"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
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

      ExOvh.V1.Cloud.container_info(service_name, container_id) |> ExOvh.request!()
  """
  @spec container_info(String.t, String.t) :: HTTPipe.Conn.t
  def container_info(service_name, container_id) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/storage/#{container_id}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
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

      ExOvh.V1.Cloud.delete_container(service_name, container_id) |> ExOvh.request!()
  """
  @spec delete_container(String.t, String.t) :: HTTPipe.Conn.t
  def delete_container(service_name, container_id) do
    req = %HTTPipe.Request{
      method: :delete,
      url: "/cloud/project/#{service_name}/storage/#{container_id}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
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

      ExOvh.V1.Cloud.modify_container_cors(service_name, container_id, "http://localhost:4001/") |> ExOvh.request!()

  ## Notes

  To get a full overview of the container details with all metadata, the Swift client should be used. To see the changes, try running the following
  command for the `container_name` associated with this `container_id`. In fact, the OVH functions are not really required, most changes can be made directly
  using queries sent via the `Swift.Cloudstorage` client.

      account = ExOvh.Swift.Cloudstorage.account()
      container = "test_container"
      Openstex.Swift.V1.container_info(container, account) |> ExOvh.Swift.Cloudstorage.request!() |> Map.get(:headers) |> Map.get("X-Container-Meta-Access-Control-Allow-Origin")
  """
  @spec modify_container_cors(String.t, String.t, String.t) :: HTTPipe.Conn.t
  def modify_container_cors(service_name, container_id, origin \\ {}) do
    body =
    %{
      "origin" => origin
     }
    |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/storage/#{container_id}/cors"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
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

      ExOvh.V1.Cloud.modify_container_cors(service_name, container_id, "http://localhost:4001/") |> ExOvh.request!()

  ## Notes

  To get a full overview of the container details with all metadata, the Swift client should be used. To see the changes, try running the following
  command for the `container_name` associated with this `container_id`. In fact, the OVH functions are not really required, most changes can be made directly
  using queries sent via the `Swift.Cloudstorage` client.

      account = ExOvh.Swift.Cloudstorage.account()
      container = "test_container"
      Openstex.Swift.V1.container_info(container, account) |> ExOvh.Swift.Cloudstorage.request!() |> Map.get(:headers)
  """
  @spec deploy_container_as_static_website(String.t, String.t) :: HTTPipe.Conn.t
  def deploy_container_as_static_website(service_name, container_id) do
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/storage/#{container_id}/static"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end



  @doc ~s"""
  List available services

  ## Api Call

      GET /cloud/project

  ## Example

      ExOvh.V1.Cloud.list_services() |> ExOvh.request!()
  """
  @spec list_services() :: HTTPipe.Conn.t
  def list_services() do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get all users

  ## Api Call

      GET /cloud/project/{serviceName}/user

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.get_users(service_name) |> ExOvh.request!()
  """
  @spec get_users(String.t) :: HTTPipe.Conn.t
  def get_users(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/user"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Create user

  ## Api Call

      POST /cloud/project/{serviceName}/user

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `description`: description ascribed to the new user.

  ## Example

      ExOvh.V1.Cloud.create_user(service_name, "ex_ovh") |> ExOvh.request!()
  """
  @spec create_user(String.t, String.t) :: HTTPipe.Conn.t
  def create_user(service_name, description) do
    body =
    %{
      "description" => description
    } |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/user"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get user details. Returns the user_id and username and other details.

  ## Api Call

      GET /cloud/project/{serviceName}/user/{userId}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: corresponds to user_id. See `get_users/1`

  ## Example

      ExOvh.V1.Cloud.get_user_details(service_name, user_id) |> ExOvh.request!()
  """
  @spec get_user_details(String.t, String.t) :: HTTPipe.Conn.t
  def get_user_details(service_name, user_id) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/user/#{user_id}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Delete a specific user.

  ## Api Call

      DELETE /cloud/project/{serviceName}/user/{userId}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: The user_id. See `get_users/1`

  ## Example

      ExOvh.V1.Cloud.delete_user(service_name, user_id) |> ExOvh.request!()
  """
  @spec delete_user(String.t, String.t) :: HTTPipe.Conn.t
  def delete_user(service_name, user_id) do
    req = %HTTPipe.Request{
      method: :delete,
      url: "/cloud/project/#{service_name}/user/#{user_id}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get RC file of OpenStack. This file is a bash script with much of the openstack credentials. Makes it easier for
  setting up a swift client from the terminal.

  ## Api Call

      GET /cloud/project/{serviceName}/user/{userId}/openrc

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: user_id for user accessing the service.
  - `region`: region for which the rc file will be created. Defaults to "SBG1" if left absent.

  ## Example

      ExOvh.V1.Cloud.download_openrc_script(service_name, user_id, "SBG1") |> ExOvh.request!()
  """
  @spec download_openrc_script(String.t, String.t, String.t) :: HTTPipe.Conn.t
  def download_openrc_script(service_name, user_id, region \\ "SBG1") do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/user/#{user_id}/openrc",
    }
    |> Url.add_query_string(%{region: region})
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Regenerate user password and other credentials.

  ## Api Call

      POST /cloud/project/{serviceName}/user/{userId}/regeneratePassword

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: user_id for accessing the project. See `get_users/1`

  ## Example

      ExOvh.V1.Cloud.regenerate_credentials(service_name, user_id) |> ExOvh.request!()
  """
  @spec regenerate_credentials(String.t, String.t) :: HTTPipe.Conn.t
  def regenerate_credentials(service_name, user_id) do
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/user/#{user_id}/regeneratePassword"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get the token for the user (very similar to keystone identity)

  ## Api Call

      POST /cloud/project/{serviceName}/user/{userId}/token

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: The swift user_id to login with. See `get_users/1`.
  - `password`: The swift password to login with. See `regenerate_credentials/2`

  ## Example

      ExOvh.V1.Cloud.swift_identity(service_name, user_id) |> ExOvh.request!()
  """
  @spec swift_identity(String.t, String.t, String.t) :: HTTPipe.Conn.t
  def swift_identity(service_name, user_id, password) do
    body =
    %{
      "password" => password
    } |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/user/#{user_id}/token"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Create a new Cloud Project.

  ## Api Call

      POST /cloud/createProject

  ## Arguments

  - `description`: project description
  - `voucher`: ovh voucher code

  ## Example

      ExOvh.V1.Cloud.create_project(description, voucher) |> ExOvh.request!()
  """
  @spec create_project(String.t, String.t) :: HTTPipe.Conn.t
  def create_project(description, voucher) do
    body =
    %{
      "description" => description,
      "voucher" => voucher
    } |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/createProject"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get services prices for the OVH public cloud.

  ## Api Call

      GET /cloud/price

  ## Arguments

  - `region`: prices for a particular region (optional)
  - `flavor_id`: ovh voucher code (optional)

  ## Example

      ExOvh.V1.Cloud.get_prices() |> ExOvh.request!()
  """
  @spec get_prices(String.t | :nil, String.t | :nil) :: HTTPipe.Conn.t
  def get_prices(region \\ :nil, flavor_id \\ :nil) do
    params =
    cond do
      region == :nil and flavor_id == :nil -> %{}
      region != :nil and flavor_id == :nil -> %{"region" => region}
      region == :nil and flavor_id != :nil -> %{"flavorId" => flavor_id}
      region != :nil and flavor_id != :nil -> %{ "region" => region, "flavorId" => flavor_id }
    end
    body = if params == %{}, do: "", else: Poison.encode!(params)
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/createProject"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get details for a given project.

  ## Api Call

      GET /cloud/project/{serviceName}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.project_info(service_name) |> ExOvh.request!()
  """
  @spec project_info(String.t) :: HTTPipe.Conn.t
  def project_info(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Modify the project description for a project.

  ## Api Call

      PUT /cloud/project/{serviceName}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.modify_project(service_name, new_description) |> ExOvh.request!()
  """
  @spec modify_project(String.t, String.t) :: HTTPipe.Conn.t
  def modify_project(service_name, new_description) do
  body =
  %{
    "description" => new_description
   } |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :put,
      url: "/cloud/project/#{service_name}"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get administration information about the project

  ## Api Call

      GET /cloud/project/{serviceName}/serviceInfos

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.project_administrative_info(service_name) |> ExOvh.request!()
  """
  @spec project_administrative_info(String.t) :: HTTPipe.Conn.t
  def project_administrative_info(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/serviceInfos"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get project quotas.

  ## Api Call

      GET /cloud/project/{serviceName}/quota

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.project_quotas(service_name) |> ExOvh.request!()
  """
  @spec project_quotas(String.t) :: HTTPipe.Conn.t
  def project_quotas(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/quota"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get project regions.

  ## Api Call

      GET /cloud/project/{serviceName}/region

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.project_regions(service_name) |> ExOvh.request!()
  """
  @spec project_regions(String.t) :: HTTPipe.Conn.t
  def project_regions(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/region"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get project details about a project region.

  ## Api Call

      GET /cloud/project/{serviceName}/region/{regionName}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.project_region_info(service_name) |> ExOvh.request!()
  """
  @spec project_region_info(String.t, String.t) :: HTTPipe.Conn.t
  def project_region_info(service_name, region_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/region/#{region_name}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get project details about a project consumption.

  *Note:* Will only allow for up to one month of data to be returned.

  ## Api Call

      GET /cloud/project/{serviceName}/consumption

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `date_from`: starting date in `ISO 8601` format. defaults to 4 weeks/28 days ago (UTC time) if left absent.
  - `date_to`: end date in `ISO 8601` format. defaults to now (UTC time) if left absent.

  ## Example

      ExOvh.V1.Cloud.project_consumption(service_name) |> ExOvh.request!()
  """
  @spec project_consumption(String.t, String.t, String.t) :: HTTPipe.Conn.t
  def project_consumption(service_name, date_from \\ :nil, date_to \\ :nil) do
    date_from = if date_from == :nil, do: Calendar.DateTime.now!("Etc/UTC") |> Calendar.DateTime.add!(-(60*60*24*28)) |> Calendar.DateTime.Format.rfc3339(), else: date_from
    date_to = if date_to == :nil, do: Calendar.DateTime.now!("Etc/UTC") |> Calendar.DateTime.Format.rfc3339(), else: date_to
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/consumption"
    }
    |> Url.add_query_string(%{from: date_from, to: date_to})
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get project details about a project bills.

  ## Api Call

      GET /cloud/project/{serviceName}/bill

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `date_from`: starting date in `ISO 8601` format. defaults to 4 weeks/28 days ago (UTC time) if left absent.
  - `date_to`: end date in `ISO 8601` format. defaults to now (UTC time) if left absent.

  ## Example

      ExOvh.V1.Cloud.project_bills(service_name) |> ExOvh.request!()
  """
  @spec project_bills(String.t, String.t, String.t) :: HTTPipe.Conn.t
  def project_bills(service_name, date_from \\ :nil, date_to \\ :nil) do
    date_from = if date_from == :nil, do: Calendar.DateTime.now!("Etc/UTC") |> Calendar.DateTime.add!(-(60*60*24*28)) |> Calendar.DateTime.Format.rfc3339(), else: date_from
    date_to = if date_to == :nil, do: Calendar.DateTime.now!("Etc/UTC") |> Calendar.DateTime.Format.rfc3339(), else: date_to
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/bill"
    }
    |> Url.add_query_string(%{from: date_from,to: date_to})
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get a list of project alert ids. These project alert ids can then be looked up in a separate request for more information.

  ## Api Call

      GET /cloud/project/{serviceName}/alerting

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.get_project_alerts(service_name) |> ExOvh.request!()
  """
  @spec get_project_alerts(String.t) :: HTTPipe.Conn.t
  def get_project_alerts(service_name) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/alerting"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Create a new project alert.

  *Notes:*
  It seems only one alert is allowed per project. To create a new one alter the old one or delete the old one and add a new one.
  Once the monthly threshold in the given currency is exceeded, then the alert email is sent.

  ## Api Call

      POST /cloud/project/{serviceName}/alerting

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `delay`: The delay between each alert in seconds. This has to be selected from an enumerable (a list). 3600 is the lowest. defaults to 3600. (1 hour)
  - `email`: The email to send the alert to.
  - `monthlyThreshold`: The maximum monetary (cash) usage allowed in one month. This is an integer value. Ask OVH about how the currency is chosen.

  ## Example

      ExOvh.V1.Cloud.create_project_alert(service_name, "email_address@email.email", 5) |> ExOvh.request!()
  """
  @spec create_project_alert(String.t, String.t, integer, String.t) :: HTTPipe.Conn.t | no_return
  def create_project_alert(service_name, email, monthly_threshold, delay \\ "3600") do
    unless is_integer(monthly_threshold), do: Og.log_r("monthly_threshold should be an integer!", __ENV__, :error) |> raise()
    body =
    %{
      "delay" => delay,
      "email" => email,
      "monthlyThreshold" => monthly_threshold
    } |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/alerting"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Get detailed information about a project alert.

  ## Api Call

      GET /cloud/project/{serviceName}/alerting/{id}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `alert_id`: The id of the project alert. See `get_project_alerts/1`

  ## Example

      ExOvh.V1.Cloud.get_project_alert_info(service_name, alert_id) |> ExOvh.request!()
  """
  @spec get_project_alert_info(String.t, String.t) :: HTTPipe.Conn.t
  def get_project_alert_info(service_name, alert_id) do
    req = %HTTPipe.Request{
      method: :get,
      url: "/cloud/project/#{service_name}/alerting/#{alert_id}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Modify an existing project alert.

  ## Api Call

      PUT /cloud/project/{serviceName}/alerting/{id}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `alert_id`: The alert to be modified.
  - `delay`: The delay between each alert in seconds. This has to be selected from an enumerable (a list). 3600 is the lowest. defaults to 3600. (1 hour)
  - `email`: The email to send the alert to.
  - `monthlyThreshold`: The maximum monetary (cash) usage allowed in one month. This is an integer value. Ask OVH about how the currency is chosen.

  ## Example

      ExOvh.V1.Cloud.modify_project_alert(service_name, alert_id, "email_address@email.email", 5) |> ExOvh.request!()
  """
  @spec modify_project_alert(String.t, String.t, String.t, integer, String.t) :: HTTPipe.Conn.t
  def modify_project_alert(service_name, alert_id, email, monthly_threshold, delay \\ "3600") do
    unless is_integer(monthly_threshold), do: Og.log_r("monthly_threshold should be an integer!", __ENV__, :error) |> raise()
    body = %{
      "delay" => delay,
      "email" => email,
      "monthlyThreshold" => monthly_threshold
    } |> Poison.encode!()
    req = %HTTPipe.Request{
      method: :put,
      url: "/cloud/project/#{service_name}/alerting/#{alert_id}"
    }
    |> Body.apply(body)
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Delete a project alert.

  ## Api Call

      DELETE /cloud/project/{serviceName}/alerting/{id}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `alert_id`: The id of the project alert. See `get_project_alerts/1`

  ## Example

      ExOvh.V1.Cloud.get_project_alert_info(service_name, alert_id) |> ExOvh.request!()
  """
  @spec delete_project_alert(String.t, String.t) :: HTTPipe.Conn.t
  def delete_project_alert(service_name, alert_id) do
    req = %HTTPipe.Request{
      method: :delete,
      url: "/cloud/project/#{service_name}/alerting/#{alert_id}"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end


  @doc ~s"""
  Terminate a cloud project.

  ## Api Call

      POST /cloud/project/{serviceName}/terminate

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.V1.Cloud.HTTPipe.Conn.terminate_project(service_name) |> ExOvh.request!()
  """
  @spec terminate_project(String.t) :: HTTPipe.Conn.t
  def terminate_project(service_name) do
    req = %HTTPipe.Request{
      method: :post,
      url: "/cloud/project/#{service_name}/terminate"
    }
    Map.put(HTTPipe.Conn.new(), :request, req)
  end

end
