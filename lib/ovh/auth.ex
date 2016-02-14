defmodule ExOvh.Ovh.Auth do
  @moduledoc ~s"""
  Houses the `prepare_request` function which delegates the function call to the appropriate
  module & function depending on the `opts` key-values.

  Ovh uses it's own custom api and also separate Openstack compliant apis so
  and these apis are quite different.
  Therefore, the request needs to be routed to the correct `prepare_request` function so
  that the correct auth credentials are put into the `options_t` in the returned
  `ExOvh.Client.query_t` query tuple.

  ## Examples of what some delegation depending on opts

      ExOvh.ovh_prepare_request(query, %{} = opts)
      calls
      ExOvh.Ovh.OvhApi.Auth.ovh_prepare_request(ExOvh, query, opts)

  -

      ExOvh.ovh_prepare_request(query, %{ openstack: :true, webstorage: "service_name" } = opts)
      calls
      ExOvh.Ovh.OpenstackApi.Webstorage.Auth.ovh_prepare_request(ExOvh, query, opts)


  ## Subsequent Request modules

  The subsequent request functions process the request by

  1. Calling the appropriate `prepare_request` function which has been delegated to.
  2. Getting the appropriate auth credentials and adding them to the headers as needed.
  3. Returning `ExOvh.Client.query_t` which is a tuple of the format {method, uri, options} which
     can then be easily used to make requests using HTTPpotion, `ovh_request` or `hubic_request`.
  """
  alias ExOvh.Ovh.Openstack.Auth, as: OpenstackAuth
  alias ExOvh.Ovh.OvhApi.Auth, as: OvhAuth


  @doc ~S"""
  Delegates the function call to the appropriate module & function depending on the `opts` key-values.

  Subsequent request functions return `{:ok, response_t}` or `{:error, response_t}`

  ## Options

      { } = opts

  The function call will be delegated to `ExOvh.Ovh.OvhApi.Auth`.

      { openstack: :true, webstorage: "<service>" } = opts

  The function call will be delegated to `ExOvh.Ovh.OpenstackApi.Webstorage.Auth`.

  `openstack: :true` - boolean - indicates whether the request is an openstack one or not.

  `webstorage: service` - String.t and is the name the cdn webstorage in your ovh stack which you which to use.
  """
  @spec prepare_request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map())
                     :: ExOvh.Client.query_t
  def prepare_request(client, {method, uri, params} = query, %{openstack: :true} = opts) do
    OpenstackAuth.prepare_request(client, query)
  end

  def prepare_request(client, {method, uri, params} = query, opts) do
    OvhAuth.prepare_request(client, query)
  end


end
