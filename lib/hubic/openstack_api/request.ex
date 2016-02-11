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
    {method, uri, options} = Auth.prepare_request(client, query)
    |> LoggingUtils.log_return(:debug)
    resp = HTTPotion.request(method, uri, options)
    |> LoggingUtils.log_return(:debug)

    if resp.status_code >= 100 and resp.status_code < 300 do
      try do
        {:ok, %{
               body: resp.body |> Poison.decode!(),
               headers: resp.headers,
               status_code: resp.status_code
              }
        }
      rescue
        _ ->
        {:ok, %{
               body: resp.body,
               headers: resp.headers,
               status_code: resp.status_code
              }
        }
      end
    else
     {:error, resp}
    end

  end



  ###################
  # Private
  ###################


end