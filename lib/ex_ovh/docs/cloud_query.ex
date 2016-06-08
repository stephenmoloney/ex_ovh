defmodule ExOvh.Services.V1.Cloud.Query.Docs do
  @moduledoc :false

  @doc :false
  def moduledoc() do
    ~s"""
    Helper functions for building queries directed at the `/cloud` part of the [OVH API](https://api.ovh.com/console/).

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


    ## TO BE ADDED

        GET /cloud/project/{serviceName}/acl
        POST /cloud/project/{serviceName}/acl
        GET /cloud/project/{serviceName}/acl/{accountId}
        DELETE /cloud/project/{serviceName}/acl/{accountId}

    ## Notes

    - `service_name` or `serviceName` corresponds to the Openstack `tenant_id`


    ## Example

        ExOvh.Services.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.request!()
    """
  end


end