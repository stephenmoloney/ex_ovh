defmodule ExOvh.Hubic.OpenstackApi.Request do
  @moduledoc :false
  alias ExOvh.Hubic.OpenstackApi.Cache
  alias ExOvh.Hubic.OpenstackApi.Auth


  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
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


end