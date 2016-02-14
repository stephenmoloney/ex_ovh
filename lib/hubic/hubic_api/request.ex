defmodule ExOvh.Hubic.HubicApi.Request do
  @moduledoc :false
  alias ExOvh.Hubic.HubicApi.Auth
  alias ExOvh.Hubic.HubicApi.Cache, as: TokenCache


  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, opts :: map, retries :: integer)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, opts, retries \\ 0) do
    {method, uri, options} = Auth.prepare_request(client, query)
    LoggingUtils.log_return({method, uri, options}, :debug)
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
      if Map.has_key?(resp.body, "error") do
        if resp.body["error"] === "invalid_token" do
          GenServer.call(TokenCache, :stop) # Restart the gen_server to recuperate state
          unless retries >= 1, do: request(query, opts, 1) # Try request one more time
        else
          {:error, resp}
        end
      else
        {:error, resp}
      end
    end

  end


end