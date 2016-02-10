defmodule ExOvh.Hubic.Auth do
  @moduledoc ~s"""
    Delegates the prepare_request to the appropriate module and function
    depending on the opts specified.
    `%{ openstack: :true }` ==> delegates the query to the OpenstackApi.Auth Module
    `%{ }` ==> delegates the query to the HubicApi.Auth Module
  """
  alias ExOvh.Hubic.OpenstackApi.Auth, as: OpenstackAuth
  alias ExOvh.Hubic.HubicApi.Auth, as: HubicAuth

  ############################
  # Public
  ############################


  @spec prepare_request(query :: ExOvh.Client.raw_query_t, opts :: map())
                     :: ExOvh.Client.query_t
  def prepare_request({method, uri, params} = query, opts), do: prepare_request(ExOvh, query, opts)

  @spec prepare_request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map())
                     :: ExOvh.Client.query_t
  def prepare_request(client, {method, uri, params} = query, %{openstack: :true} = opts) do
    OpenstackAuth.prepare_request(client, query)
  end
  def prepare_request(client, {method, uri, params} = query, opts) do
    HubicAuth.prepare_request(client, query)
  end


  ############################
  # Private
  ############################


end
