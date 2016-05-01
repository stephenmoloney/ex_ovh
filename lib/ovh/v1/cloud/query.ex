defmodule ExOvh.Ovh.V1.Cloud.Query do
  @moduledoc ~s"""
  Helper functions for building queries directed at the `/cloud` part of the ovh api.

  ## Notes

  | Function | Description | OVH API call |
  |---|---|---|
  | `list_services/0` | <small>List available services</small> | <sub><sup>GET /cloud/project</sup></sub> |
  | `get_users/1` | <small>Get all users</small> | <sub><sup>GET /cloud/project/{serviceName}/user</sup></sub> |
  | `create_user/2` | <small>Create user</small> | <sub><sup>POST /cloud/project/{serviceName}/user</sup></sub> |
  | `get_user_details/2` | <small>Get user details</small> | <sub><sup>GET /cloud/project/{serviceName}/user/{userId}</sup></sub> |
  | `delete_user/2` | <small>Delete user</small> | <sub><sup>DELETE /cloud/project/{serviceName}/user/{userId}</sup></sub> |
  | `download_openrc_script/3` | <small>Get RC file of OpenStack</small> | <sub><sup>GET /cloud/project/{serviceName}/user/{userId}/openrc</sup></sub> |
  | `regenerate_credentials/2`  | <small>Regenerate user credentials including password</small> | <sub><sup>POST /cloud/project/{serviceName}/user/{userId}/regeneratePassword</sup></sub> |
  | `swift_identity/3` | <small>Gets a json object similar to that returned by Keystone Identity. Includes the 'X-Auth-Token'</small> | <sub><sup>POST /cloud/project/{serviceName}/user/{userId}/token</sup></sub> |


  ## TODO

  POST /cloud/createProject Start a new cloud project
  GET /cloud/price Get services prices
  GET /cloud/project/{serviceName} Get this object properties
  PUT /cloud/project/{serviceName} Alter this object properties
  GET /cloud/project/{serviceName}/acl Get ACL on your cloud project
  POST /cloud/project/{serviceName}/acl
  GET /cloud/project/{serviceName}/serviceInfos
  GET /cloud/project/{serviceName}/quota Get project quotas
  GET /cloud/project/{serviceName}/region Get regions
  GET /cloud/project/{serviceName}/region/{regionName}
  GET /cloud/project/{serviceName}/consumption
  GET /cloud/project/{serviceName}/bill


  ## Example

      ExOvh.Ovh.V1.Cloud.Cloudstorage.Query.get_containers(service_name) |> ExOvh.request!()
  """
  alias ExOvh.Ovh.Query


  @doc ~s"""
  GET /cloud/project List available services

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.list_services() |> ExOvh.request!()
  """
  @spec list_services() :: Query.t
  def list_services() do
    %Query{
          method: :get,
          uri: "/cloud/services",
          params: :nil
          }
  end


  @doc ~s"""
  GET /cloud/project/{serviceName}/user Get all users

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.get_users(service_name) |> ExOvh.request!()
  """
  @spec get_users(String.t) :: Query.t
  def get_users(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/user",
          params: :nil
          }
  end


  @doc ~s"""
  POST /cloud/project/{serviceName}/user Create user

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.create_user(service_name, "ex_ovh") |> ExOvh.request!()
  """
  @spec create_user(String.t, String.t) :: Query.t
  def create_user(service_name, description) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/user",
          params: %{
                    "description" => description
                  }
                  |> Poison.encode!()
          }
  end


  @doc ~s"""
  GET /cloud/project/{serviceName}/user/{userId} Get user details

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.get_user_details(service_name, user_id) |> ExOvh.request!()
  """
  @spec get_user_details(String.t, String.t) :: Query.t
  def get_user_details(service_name, user_id) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/user/#{user_id}",
          params: :nil
          }
  end


  @doc ~s"""
  DELETE /cloud/project/{serviceName}/user/{userId} Delete user

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.delete_user(service_name, user_id) |> ExOvh.request!()
  """
  @spec delete_user(String.t, String.t) :: Query.t
  def delete_user(service_name, user_id) do
    %Query{
          method: :delete,
          uri: "/cloud/project/#{service_name}/user/#{user_id}",
          params: :nil
          }
  end


  @doc ~s"""
  GET /cloud/project/{serviceName}/user/{userId}/openrc Get RC file of OpenStack

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.download_openrc_script(service_name, user_id, "SBG1") |> ExOvh.request!()
  """
  @spec download_openrc_script(String.t, String.t, String.t) :: Query.t
  def download_openrc_script(service_name, user_id, region \\ "SBG1") do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/user/#{user_id}/openrc",
          params: %{
                    region: region
                  }
          }
  end


  @doc ~s"""
  POST /cloud/project/{serviceName}/user/{userId}/regeneratePassword Regenerate user password

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.regenerate_credentials(service_name, user_id) |> ExOvh.request!()
  """
  @spec regenerate_credentials(String.t, String.t) :: Query.t
  def regenerate_credentials(service_name, user_id) do
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/user/#{user_id}/regeneratePassword",
          params: :nil
          }
  end


  @doc ~s"""
  POST /cloud/project/{serviceName}/user/{userId}/token  Get the token for the user (very similar to
  keystone identity)

  ## Example

      ExOvh.Ovh.V1.Cloud.Query.swift_identity(service_name, user_id) |> ExOvh.request!()
  """
  @spec swift_identity(String.t, String.t, String.t) :: Query.t
  def swift_identity(service_name, user_id, password) do
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/user/#{user_id}/token",
          params: %{
                  "password" => password
                  }
                  |> Poison.encode!()
          }
  end




end