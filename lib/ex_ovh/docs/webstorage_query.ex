defmodule ExOvh.Services.V1.Webstorage.Query.Docs do
  @moduledoc :false

  @doc :false
  def moduledoc() do
    ~s"""
    Helper functions for building queries directed at the `/cdn/webstorage` part of the [OVH API](https://api.ovh.com/console/).

    ## Functions Summary

    | Function | Description | OVH API call |
    |---|---|---|
    | `get_services/0` | <small>Get a list of all webstorage cdn services.</small> | <sub><sup>GET /v1/​cdn/webstorage</sup></sub> |
    | `get_service/1` | <small>Get the domain, server and storage limits for a specific webstorage cdn service</small> | <sub><sup>GET /v1/​cdn/webstorage​/{serviceName}</sup></sub> |
    | `get_service_info/1` | <small>Get a administrative details for a specific webstorage cdn service</small> | <sub><sup>GET /v1/​cdn/webstorage​/{serviceName}/serviceInfos</sup></sub> |
    | `get_service_stats/2`  | <small>Get statistics for a specific webstorage cdn service</small> | <sub><sup>GET /v1/​cdn/webstorage​/{serviceName}/statistics</sup></sub> |
    | `get_credentials/1` | <small>Get credentials for using the swift compliant api</small> | <sub><sup>GET /v1/​cdn/webstorage​/{serviceName}/statistics</sup></sub> |


    ## Example

        ExOvh.Services.V1.Webstorage.Query.get_services() |> ExOvh.request()
    """
  end


end