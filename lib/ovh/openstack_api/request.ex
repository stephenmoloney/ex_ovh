defmodule ExOvh.Ovh.OpenstackApi.Request do
  @moduledoc ~s"""
  Delegate the request to the appropriate module depending on the query uri. <<REMOVE LINE>>
  Delegate the request to the appropriate module depending on the opts.

    For example,
                /cdn/webstorage ==> ExOvh.Ovh.Openstack.Webstorage.Request
                /cdn/cloud ==> ExOvh.Ovh.Openstack.Cloud.Request
  """
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Request, as: WebStorage


  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, %{ webstorage: service } = opts) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    LoggingUtils.log_return("***SERVICE*** #{service}", :warn)
    WebStorage.request(client, query, service)
  end


end