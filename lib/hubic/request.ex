defmodule ExOvh.Hubic.Request do
  @moduledoc ~s"""
    Delegates the request to the correct module and functions
    according to what the opts map specifies.
    `%{ openstack: :true }` ==> delegates the query to the OpenstackApi Module
    `%{ }` ==> delegates the query to the HubicApi Module
  """
  alias ExOvh.Hubic.HubicApi.Request, as: Hub
  alias ExOvh.Hubic.OpenstackApi.Request, as: Open


  ###################
  # Public
  ###################

  @spec request(query :: ExOvh.Client.raw_query_t, opts :: map)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request({method, uri, params} = query, opts), do: request(ExOvh, query, opts)

  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, %{ openstack: :true } = opts), do: Open.request(client, query)
  def request(client, {method, uri, params} = query, opts), do: Hub.request(client, query)

  ###################
  # Private
  ###################


end