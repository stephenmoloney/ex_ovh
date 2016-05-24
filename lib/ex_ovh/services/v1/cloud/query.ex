defmodule ExOvh.Services.V1.Cloud.Query do
  @moduledoc Module.concat(__MODULE__, Docs).moduledoc()
  alias ExOvh.Query


  @doc ~s"""
  List available services

  ## Api Call

      GET /cloud/project

  ## Example

      ExOvh.Services.V1.Cloud.Query.list_services() |> ExOvh.Ovh.request!()
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
  Get all users

  ## Api Call

      GET /cloud/project/{serviceName}/user

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.get_users(service_name) |> ExOvh.Ovh.request!()
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
  Create user

  ## Api Call

      POST /cloud/project/{serviceName}/user

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `description`: description ascribed to the new user.

  ## Example

      ExOvh.Services.V1.Cloud.Query.create_user(service_name, "ex_ovh") |> ExOvh.Ovh.request!()
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
  Get user details. Returns the user_id and username and other details.

  ## Api Call

      GET /cloud/project/{serviceName}/user/{userId}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: corresponds to user_id. See `get_users/1`

  ## Example

      ExOvh.Services.V1.Cloud.Query.get_user_details(service_name, user_id) |> ExOvh.Ovh.request!()
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
  Delete a specific user.

  ## Api Call

      DELETE /cloud/project/{serviceName}/user/{userId}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: The user_id. See `get_users/1`

  ## Example

      ExOvh.Services.V1.Cloud.Query.delete_user(service_name, user_id) |> ExOvh.Ovh.request!()
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
  Get RC file of OpenStack. This file is a bash script with much of the openstack credentials. Makes it easier for
  setting up a swift client from the terminal.

  ## Api Call

      GET /cloud/project/{serviceName}/user/{userId}/openrc

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: user_id for user accessing the service.
  - `region`: region for which the rc file will be created. Defaults to "SBG1" if left absent.

  ## Example

      ExOvh.Services.V1.Cloud.Query.download_openrc_script(service_name, user_id, "SBG1") |> ExOvh.Ovh.request!()
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
  Regenerate user password and other credentials.

  ## Api Call

      POST /cloud/project/{serviceName}/user/{userId}/regeneratePassword

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: user_id for accessing the project. See `get_users/1`

  ## Example

      ExOvh.Services.V1.Cloud.Query.regenerate_credentials(service_name, user_id) |> ExOvh.Ovh.request!()
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
  Get the token for the user (very similar to keystone identity)

  ## Api Call

      POST /cloud/project/{serviceName}/user/{userId}/token

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `user_id`: The swift user_id to login with. See `get_users/1`.
  - `password`: The swift password to login with. See `regenerate_credentials/2`

  ## Example

      ExOvh.Services.V1.Cloud.Query.swift_identity(service_name, user_id) |> ExOvh.Ovh.request!()
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


  @doc ~s"""
  Create a new Cloud Project.

  ## Api Call

      POST /cloud/createProject

  ## Arguments

  - `description`: project description
  - `voucher`: ovh voucher code

  ## Example

      ExOvh.Services.V1.Cloud.Query.create_project(description, voucher) |> ExOvh.Ovh.request!()
  """
  @spec create_project(String.t, String.t) :: Query.t
  def create_project(description, voucher) do
    %Query{
          method: :post,
          uri: "/cloud/createProject",
          params: %{
                  "description" => description,
                  "voucher" => voucher
                  }
                  |> Poison.encode!()
          }
  end


  @doc ~s"""
  Get services prices for the OVH public cloud.

  ## Api Call

      GET /cloud/price

  ## Arguments

  - `region`: prices for a particular region (optional)
  - `flavor_id`: ovh voucher code (optional)

  ## Example

      ExOvh.Services.V1.Cloud.Query.get_prices() |> ExOvh.Ovh.request!()
  """
  @spec get_prices(String.t | :nil, String.t | :nil) :: Query.t
  def get_prices(region \\ :nil, flavor_id \\ :nil) do
    params =
    cond do
      region == :nil and flavor_id == :nil -> :nil
      region != :nil and flavor_id == :nil -> %{"region" => region}
      region == :nil and flavor_id != :nil -> %{"flavorId" => flavor_id}
      region != :nil and flavor_id != :nil -> %{ "region" => region, "flavorId" => flavor_id }
    end
    %Query{
          method: :get,
          uri: "/cloud/createProject",
          params: params
          }
  end


  @doc ~s"""
  Get details for a given project.

  ## Api Call

      GET /cloud/project/{serviceName}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.project_info(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_info(String.t) :: Query.t
  def project_info(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}",
          params: :nil
          }
  end


  @doc ~s"""
  Modify the project description for a project.

  ## Api Call

      PUT /cloud/project/{serviceName}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.modify_project(service_name, new_description) |> ExOvh.Ovh.request!()
  """
  @spec modify_project(String.t, String.t) :: Query.t
  def modify_project(service_name, new_description) do
    %Query{
          method: :put,
          uri: "/cloud/project/#{service_name}",
          params: %{
                    "description" => new_description
                   }
                   |> Poison.encode!()
          }
  end


  @doc ~s"""
  Get administration information about the project

  ## Api Call

      GET /cloud/project/{serviceName}/serviceInfos

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.project_administrative_info(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_administrative_info(String.t) :: Query.t
  def project_administrative_info(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/serviceInfos",
          params: :nil
          }
  end


  @doc ~s"""
  Get project quotas.

  ## Api Call

      GET /cloud/project/{serviceName}/quota

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.project_quotas(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_quotas(String.t) :: Query.t
  def project_quotas(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/quota",
          params: :nil
          }
  end


  @doc ~s"""
  Get project regions.

  ## Api Call

      GET /cloud/project/{serviceName}/region

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.project_regions(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_regions(String.t) :: Query.t
  def project_regions(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/region",
          params: :nil
          }
  end


  @doc ~s"""
  Get project details about a project region.

  ## Api Call

      GET /cloud/project/{serviceName}/region/{regionName}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.project_region_info(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_region_info(String.t, String.t) :: Query.t
  def project_region_info(service_name, region_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/region/#{region_name}",
          params: :nil
          }
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

      ExOvh.Services.V1.Cloud.Query.project_consumption(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_consumption(String.t, String.t, String.t) :: Query.t
  def project_consumption(service_name, date_from \\ :nil, date_to \\ :nil) do
    date_from = if date_from == :nil, do: Calendar.DateTime.now_utc!() |> Calendar.DateTime.add!(-(60*60*24*28)) |> Calendar.DateTime.Format.rfc3339(), else: date_from
    date_to = if date_to == :nil, do: Calendar.DateTime.now_utc!() |> Calendar.DateTime.Format.rfc3339(), else: date_to
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/consumption",
          params: %{from: date_from, to: date_to}
          }
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

      ExOvh.Services.V1.Cloud.Query.project_bills(service_name) |> ExOvh.Ovh.request!()
  """
  @spec project_bills(String.t, String.t, String.t) :: Query.t
  def project_bills(service_name, date_from \\ :nil, date_to \\ :nil) do
    date_from = if date_from == :nil, do: Calendar.DateTime.now_utc!() |> Calendar.DateTime.add!(-(60*60*24*28)) |> Calendar.DateTime.Format.rfc3339(), else: date_from
    date_to = if date_to == :nil, do: Calendar.DateTime.now_utc!() |> Calendar.DateTime.Format.rfc3339(), else: date_to
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/bill",
          params: %{from: date_from, to: date_to}
          }
  end


  @doc ~s"""
  Get a list of project alert ids. These project alert ids can then be looked up in a separate query for more information.

  ## Api Call

      GET /cloud/project/{serviceName}/alerting

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.get_project_alerts(service_name) |> ExOvh.Ovh.request!()
  """
  @spec get_project_alerts(String.t) :: Query.t
  def get_project_alerts(service_name) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/alerting",
          params: :nil
          }
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

      ExOvh.Services.V1.Cloud.Query.create_project_alert(service_name, "email_address@email.email", 5) |> ExOvh.Ovh.request!()
  """
  @spec create_project_alert(String.t, String.t, integer, String.t) :: Query.t | no_return
  def create_project_alert(service_name, email, monthly_threshold, delay \\ "3600") do
    unless is_integer(monthly_threshold), do: Og.log_return("monthly_threshold should be an integer!", __ENV__, :error) |> raise()
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/alerting",
          params: %{
                  "delay" => delay,
                  "email" => email,
                  "monthlyThreshold" => monthly_threshold
                  } |> Poison.encode!()
          }
  end


  @doc ~s"""
  Get detailed information about a project alert.

  ## Api Call

      GET /cloud/project/{serviceName}/alerting/{id}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `alert_id`: The id of the project alert. See `get_project_alerts/1`

  ## Example

      ExOvh.Services.V1.Cloud.Query.get_project_alert_info(service_name, alert_id) |> ExOvh.Ovh.request!()
  """
  @spec get_project_alert_info(String.t, String.t) :: Query.t
  def get_project_alert_info(service_name, alert_id) do
    %Query{
          method: :get,
          uri: "/cloud/project/#{service_name}/alerting/#{alert_id}",
          params: :nil
          }
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

      ExOvh.Services.V1.Cloud.Query.modify_project_alert(service_name, alert_id, "email_address@email.email", 5) |> ExOvh.Ovh.request!()
  """
  @spec modify_project_alert(String.t, String.t, String.t, integer, String.t) :: Query.t
  def modify_project_alert(service_name, alert_id, email, monthly_threshold, delay \\ "3600") do
    unless is_integer(monthly_threshold), do: Og.log_return("monthly_threshold should be an integer!", __ENV__, :error) |> raise()
    %Query{
          method: :put,
          uri: "/cloud/project/#{service_name}/alerting/#{alert_id}",
          params: %{
                  "delay" => delay,
                  "email" => email,
                  "monthlyThreshold" => monthly_threshold
                  } |> Poison.encode!()
          }
  end


  @doc ~s"""
  Delete a project alert.

  ## Api Call

      DELETE /cloud/project/{serviceName}/alerting/{id}

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`
  - `alert_id`: The id of the project alert. See `get_project_alerts/1`

  ## Example

      ExOvh.Services.V1.Cloud.Query.get_project_alert_info(service_name, alert_id) |> ExOvh.Ovh.request!()
  """
  @spec delete_project_alert(String.t, String.t) :: Query.t
  def delete_project_alert(service_name, alert_id) do
    %Query{
          method: :delete,
          uri: "/cloud/project/#{service_name}/alerting/#{alert_id}",
          params: :nil
          }
  end


  @doc ~s"""
  Terminate a cloud project.

  ## Api Call

      POST /cloud/project/{serviceName}/terminate

  ## Arguments

  - `service_name`: corresponds to project_id or tenant_id. See `list_services/0`

  ## Example

      ExOvh.Services.V1.Cloud.Query.terminate_project(service_name) |> ExOvh.Ovh.request!()
  """
  @spec terminate_project(String.t) :: Query.t
  def terminate_project(service_name) do
    %Query{
          method: :post,
          uri: "/cloud/project/#{service_name}/terminate",
          params: :nil
          }
  end



end