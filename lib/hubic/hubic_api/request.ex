defmodule ExOvh.Hubic.HubicApi.Request do
  alias ExOvh.Hubic.HubicApi.Auth
  alias ExOvh.Hubic.HubicApi.Cache, as: TokenCache


  ###################
  # Public
  ###################


  @doc "Api for requests to the hubic custom api"
  @spec request(query :: ExOvh.Client.raw_query_t)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request({method, uri, params} = query), do: request(ExOvh, query, 0)

  @spec request(client :: atom, query :: ExOvh.Client.raw_query_t, retries :: integer)
                :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query, retries \\ 0) do
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
      if Map.has_key?(resp.body, "error") do
        #error = Map.get(body, "error") <> " :: " <> Map.get(body, "error_description")
        if resp.body["error"] === "invalid_token" do
          GenServer.call(TokenCache, :stop) # Restart the gen_server to recuperate state
          unless retries >= 1, do: request(query, 1) # Try request one more time
        else
          {:error, resp}
        end
      else
        {:error, resp}
      end
    end

  end

  ###################
  # Private
  ###################


end