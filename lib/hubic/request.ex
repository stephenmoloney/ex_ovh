defmodule ExOvh.Hubic.Request do
  @moduledoc ~S"""
  Contains the `request` function which delegates the request
  to the correct module and functions depending on the parameters in `opts`.

  Hubic uses it's own custom api and also a distinct Openstack compliant api so
  and these apis are quite different.
  Therefore, the request needs to be routed to the correct `prepare_request` function so
  that the correct auth credentials are put into the `options_t` in the returned
  `ExOvh.Client.query_t` query tuple.

  This module's request function delegates the query to the correct `prepare_request`
  function by pattern matching on the `opts` map.

  ## Routing/Delegating depending on opts

  `%{ }` -> `ExOvh.Hubic.HubicApi.Request`

  `%{ openstack: :true}` -> `ExOvh.Hubic.OpenstackApi.Request`

  ## Subsequent Request modules

  The subsequent request modules process the request by

  1. Calling the appropriate `prepare_request` function which has been delegated to.
  2. Making the actual request with `HTTPotion`
  3. Returning the response as `{:ok, response_t}` or `{:error, response_t}`
  """
  alias ExOvh.Hubic.HubicApi.Request, as: Hub
  alias ExOvh.Hubic.OpenstackApi.Request, as: Open


  @doc ~S"""
  Redirects the query to the appropriate function dependeing on the `opts` key-values.

  Subsequent request functions return `{:ok, response_t}` or `{:error, response_t}`

  ## Options

      { } = opts

  The request will be delegated to `ExOvh.Hubic.HubicApi.Request` and processed as a hubic api request.

      { openstack: :true } = opts

  The request will be delegated to `ExOvh.Hubic.OpenstackApi.Request` and processed as an openstack api request.
  """
  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, %{ openstack: :true } = opts) do
    Open.request(client, query)
  end

  def request(client, {method, uri, params} = query, opts) do
    Hub.request(client, query)
  end


end