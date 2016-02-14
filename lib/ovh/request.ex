defmodule ExOvh.Ovh.Request do
  @moduledoc ~S"""
  Houses the `request` function which delegates the function call to the appropriate
  module & function depending on the `opts` key-values.

  Ovh uses it's own custom api and also separate Openstack compliant apis so
  and these apis are quite different.
  Therefore, the request needs to be routed to the correct `request` function so
  that the correct auth credentials are put into the `options_t` in the returned
  `ExOvh.Client.query_t` query tuple.

  ## Examples of what some delegation depending on opts

      ExOvh.ovh_request(query, %{} = opts)
      calls
      ExOvh.Ovh.OvhApi.Request.request(ExOvh, query, opts)

  -

      ExOvh.ovh_request(query, %{ openstack: :true, webstorage: "service_name" } = opts)
      calls
      ExOvh.Ovh.OpenstackApi.Webstorage.Request.request(ExOvh, query, opts)


  ## Subsequent Request modules

  The subsequent request functions process the request by

  1. Calling the appropriate `prepare_request` function which has been delegated to.
  2. Making the actual request with `HTTPotion`
  3. Returning the response as `{:ok, response_t}` or `{:error, response_t}`
  """
  alias ExOvh.Ovh.OvhApi.Request, as: Ovh
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Request, as: Webstorage


  @doc ~S"""
  Delegates the function call to the appropriate module & function depending on the `opts` key-values.

  Subsequent request functions return `{:ok, response_t}` or `{:error, response_t}`

  ## Options

      { } = opts

  The function call will be delegated to `ExOvh.Ovh.OvhApi.Request` and processed as a hubic api request.

      { openstack: :true, webstorage: service } = opts

  The function call will be delegated to `ExOvh.Ovh.OpenstackApi.Webstorage.Request`.

  `openstack: :true` - boolean - indicates whether the request is an openstack one or not.

  `webstorage: service` - String.t and is the name the cdn webstorage in your ovh stack which you which to use.
  """
  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, %{ openstack: :true, webstorage: service } = opts) do
    Webstorage.request(client, query, opts)
  end

  def request(client, {method, uri, params} = query, opts) do
    Ovh.request(client, query, opts)
  end


end