defmodule ExOvh.Ovh.Request do
  @moduledoc ~S"""
  Contains the `request` function which delegates the request
  to the correct module and functions depending on the parameters in `opts`.

  Ovh uses it's own custom api and also separate Openstack compliant apis so
  and these apis are quite different.
  Therefore, the request needs to be routed to the correct `prepare_request` function so
  that the correct auth credentials are put into the `options_t` in the returned
  `ExOvh.Client.query_t` query tuple.

  This module's request function delegates the query to the correct `prepare_request`
  function by pattern matching on the `opts` map.

  ## Routing/Delegating depending on opts

  `%{ }` -> `ExOvh.Ovh.OvhApi.Request`

  `%{ openstack: :true, webstorage: "service_name" }` -> `ExOvh.Ovh.OpenstackApi.Webstorage.Request`

  ## Subsequent Request modules

  The subsequent request modules process the request by

  1. Calling the appropriate `prepare_request` function which has been delegated to.
  2. Making the actual request with `HTTPotion`
  3. Returning the response as `{:ok, response_t}` or `{:error, response_t}`
  """
  alias ExOvh.Ovh.OvhApi.Request, as: Ovh
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Request, as: Webstorage


  @doc ~S"""
  Redirects the query to the appropriate function dependeing on the `opts` key-values.

  Subsequent request functions return `{:ok, response_t}` or `{:error, response_t}`

  ## Options

      { } = opts

  The request will be delegated to `ExOvh.Ovh.OvhApi.Request` and processed as a hubic api request.

      { openstack: :true, webstorage: service } = opts

  The request will be delegated to `ExOvh.Ovh.OpenstackApi.Webstorage.Request`
  and processed as an openstack api request with the service value. The `service` value is a String.t
  and is the name the cdn webstorage in your ovh stack which you which to use.
  """
  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, %{ openstack: :true, webstorage: service } = opts) do
    Webstorage.request(client, query, service)
  end

  def request(client, {method, uri, params} = query, opts) do
    Ovh.request(client, query)
  end


end