defmodule ExOvh.Hubic.OpenstackApi.Request do
  alias ExOvh.Hubic.OpenstackApi.Cache
  alias ExOvh.Hubic.OpenstackApi.Auth

  ###################
  # Public
  ###################


  @doc "For requests to the hubic openstack compliant api"
  @spec request(query :: ExOvh.Client.raw_query_t)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request({method, uri, params} = query), do: request(ExOvh, query)


  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query) do
    {method, uri, options} = Auth.prep_request(client, query)
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



  ###################
  # Private
  ###################


end