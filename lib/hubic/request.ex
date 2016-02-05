defmodule ExOvh.Hubic.Request do
  alias Poison
  alias HTTPotion
  alias ExOvh.Hubic.Auth
  alias ExOvh.Hubic.TokenCache
  alias ExOvh.Hubic.Defaults


  ###################
  # Public
  ###################


  @doc "Api for requests to the hubic custom api"
  @spec request(method :: atom, uri :: String.t, params :: map, retries :: integer) :: map
  def request(method, uri, params \\ :nil), do: request(ExOvh, method, uri, params, 0)


  def request(client, method, uri, params, retries \\ 0) do
    {method, uri, options} = Auth.prep_request(client, method, uri, params)
    resp = HTTPotion.request(method, uri, options)
    resp =
    %{
      body: resp.body |> Poison.decode!(),
      headers: resp.headers |> Enum.into(%{}),
      status_code: resp.status_code
    }
    |> LoggingUtils.log_return(:debug)
    body = resp |> Map.get(:body)
    if Map.has_key?(body, "error") do
      error = Map.get(body, "error") <> " :: " <> Map.get(body, "error_description")
      if body["error"] === "invalid_token" do
        # Restart the gen_server to recuperate state
        GenServer.call(TokenCache, :stop)
        # Try request one more time
        unless retries >= 1 do
          request(method, uri, body, 1)
        end
      else
        error
      end
    else
      body
    end
  end



  ###################
  # Private
  ###################



end