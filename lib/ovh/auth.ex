defmodule ExOvh.Ovh.Auth do
  @moduledoc ~s"""
    Delegates the prepare_request to the appropriate module and function
    depending on the opts specified.
    `%{ openstack: :true }` ==> delegates the query to the OpenstackApi.Auth Module
    `%{ }` ==> delegates the query to the HubicApi.Auth Module
  """
  alias ExOvh.Ovh.Openstack.Auth, as: OpenstackAuth
  alias ExOvh.Ovh.OvhApi.Auth, as: OvhAuth

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
    OvhAuth.prepare_request(client, query)
  end


  ############################
  # Private
  ############################


end
