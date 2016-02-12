defmodule ExOvh.Ovh.OpenstackApi.Request do
  @moduledoc ~s"""
  Delegate the request to the appropriate module depending on the query uri.

    For example,
                /cdn/webstorage ==> ExOvh.Ovh.Openstack.Webstorage.Request
                /cdn/cloud ==> ExOvh.Ovh.Openstack.Cloud.Request
  """
  alias ExOvh.Ovh.Openstack.Webstorage.Request, as: WebStorage


  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query) do
    # cond do --> check for various request types .. raise if none found.
    WebStorage.request(client, query)
  end


end