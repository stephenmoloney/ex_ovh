defmodule ExOvh.Ovh.OpenstackApi.Webstorage.Request do
  @moduledoc :false
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Auth


  @spec request(client :: atom, query :: ExOvh.Client.query_t, service :: String.t)
               :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, %{ webstorage: service } = opts) do
    Og.context(__ENV__, :debug)

    {method, uri, options} = Auth.prepare_request(client, query, service)
    resp = HTTPotion.request(method, uri, options)
    |> Og.log_return(:debug)

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


end

