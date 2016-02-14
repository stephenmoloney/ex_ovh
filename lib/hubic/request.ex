defmodule ExOvh.Hubic.Request do
  @moduledoc ~S"""
  Houses the `request` function which delegates the function call to the appropriate
  module & function depending on the `opts` key-values.

  Hubic uses it's own custom api and also separate Openstack compliant apis so
  and these apis are quite different.
  Therefore, the request needs to be routed to the correct `request` function so
  that the correct auth credentials are put into the `options_t` in the returned
  `ExOvh.Client.query_t` query tuple.

  ## Examples of what some delegation depending on opts

      ExOvh.hubic_request(query, %{} = opts)
      calls
      ExOvh.Hubic.HubicApi.Request.request(ExOvh, query, opts)

  -

      ExOvh.hubic_request(query, %{ openstack: :true } = opts)
      calls
      ExOvh.Hubic.OpenstackApi.Request.request(ExOvh, query, opts)


  ## Subsequent Request modules

  The subsequent request functions process the request by

  1. Calling the appropriate `prepare_request` function which has been delegated to.
  2. Making the actual request with `HTTPotion`
  3. Returning the response as `{:ok, response_t}` or `{:error, response_t}`
  """
  alias ExOvh.Hubic.HubicApi.Request, as: Hub
  alias ExOvh.Hubic.OpenstackApi.Request, as: Open


  @doc ~S"""
  Delegates the function call to the appropriate module & function depending on the `opts` key-values.

  Subsequent request functions return `{:ok, response_t}` or `{:error, response_t}`

  ## Options

      { } = opts

  The function call will be delegated to `ExOvh.Hubic.HubicApi.Request` and processed as a hubic api request.

      { openstack: :true } = opts

  The function call will be delegated to `ExOvh.Hubic.OpenstackApi.Request`.

  `openstack: :true` - boolean - indicates whether the request is an openstack one or not.
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