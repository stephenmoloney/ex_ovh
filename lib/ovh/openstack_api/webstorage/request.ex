defmodule ExOvh.Ovh.Openstack.Webstorage.Request do
  alias ExOvh.Ovh.Openstack.Webstorage.Auth
  alias ExOvh.Ovh.OvhApi.Cache, as: ClientCache


  ############################
  # Public
  ############################


  @spec request(client :: atom, query :: ExOvh.Client.query_t)
               :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query) do
    config = config(client)
    {method, uri, options} = Auth.prepare_request(client, query)
    resp = HTTPotion.request(method, uri, options)
    resp =
    %{
      body: resp.body |> Poison.decode!(),
      headers: resp.headers,
      status_code: resp.status_code
    }
    if resp.status_code >= 100 and resp.status_code < 300 do
     {:ok, resp}
    else
     {:error, resp}
    end
  end


  ############################
  # Private
  ############################


  defp config(), do: ClientCache.get_config(ExOvh)
  defp config(client), do: ClientCache.get_config(client)


end

