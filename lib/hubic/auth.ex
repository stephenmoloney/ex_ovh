defmodule ExOvh.Hubic.Auth do
  @moduledoc "Gets the access and refresh token for access the hubic api"
  alias ExOvh.Hubic.Defaults
  alias ExOvh.Hubic.TokenCache, as: Cache
  @timeout 20_000


  ###################
  # Public
  ###################
  
  @spec prep_request(method :: atom, uri :: String.t, params :: map) :: tuple
  def prep_request(method, uri, params), do: prep_request(ExOvh, method, uri, params)


  @spec prep_request(client :: atom, method :: atom, uri :: String.t, params :: map) :: tuple
  def prep_request(client, method, uri, params)
  def prep_request(client, method, uri, params) when method in [:get, :delete] do
    config = config(client)
    |> LoggingUtils.log_return(:debug)
    uri = uri(config, uri)
    |> LoggingUtils.log_return(:debug)
    if params !== :nil and params !== "", do: uri = uri <> URI.encode_query(params)
    options = [ headers: headers(method), timeout: @timeout ]
    {method, uri, options}
  end

  def prep_request(client, method, uri, params) when method in [:post, :put] do
    config = config(client)
    uri = uri(config, uri)
    if params !== "" and params !== :nil, do: params = Poison.encode!(params)
    options = [ body: params, headers: headers(method), timeout: @timeout ]
    {method, uri, options}
  end

  def prep_request(client, method, uri, params) when method in [:get, :delete] do
    config = config(client)
    uri = uri(config, uri)
    if params !== :nil and params !== "", do: uri = uri <> URI.encode_query(params)
    options = [ headers: headers(method), timeout: @timeout ]
    {method, uri, options}
  end

  def prep_request(client, method, uri, params) when method in [:post, :put] do
    config = config(client)
    uri = uri(config, uri)
    if params !== "" and params !== :nil and method in [:post, :put], do: params = Poison.encode!(params)
    options = [ body: params, headers: headers(method), timeout: @timeout ]
    {method, uri, options}
  end



  @doc """
  - It is necessary to perform this request every time the access token expires.
  - The refresh token needs to be available to perform this request.
  - returned map structure is as follows:
    %{
      "access_token" => "access_token",
      "expires_in" => 21600,
      "token_type" => "Bearer"
     }
  """
  @spec get_latest_access_token(refresh_token :: String.t, config :: map) :: map
  def get_latest_access_token(refresh_token, config) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    auth_credentials = config.client_id <> ":" <> config.client_secret
    auth_credentials_base64 = Base.encode64(auth_credentials)
    req_body = "refresh_token=" <> refresh_token <>
                "&grant_type=refresh_token"
    headers = [
               "Content-Type": "application/x-www-form-urlencoded",
               "Authorization": "Basic " <> auth_credentials_base64
              ]
    req_options = [
                  body: req_body,
                  headers: headers,
                  timeout: @timeout
                  ]
    resp = HTTPotion.request(:post, hubic_token_uri(config), req_options)
    resp =
    %{
      body: resp.body |> Poison.decode!(),
      headers: resp.headers |> Enum.into(%{}),
      status_code: resp.status_code
    }
    |> LoggingUtils.log_return(:debug)
    if Map.has_key?(resp, "error") do
      error = Map.get(resp, "error") <> " :: " <> Map.get(resp, "error_description")
      raise error
    end
    body = resp |> Map.get(:body)
  end


  ###################
  # Private
  ###################

  defp default_headers(), do: ["Authorization": "Bearer " <> Cache.get_token()]
  defp headers(method) when method in [:post, :put] do
    default_headers() ++
    [
      "Content-Type": "application/x-www-form-urlencoded"
    ]
  end
  defp headers(method) when method in [:get, :delete], do: default_headers()


  defp config(), do: Cache.get_config(ExOvh)
  defp config(client), do: Cache.get_config(client)
  defp api_version(config), do: config[:api_version]
  defp uri(config, uri), do: hubic_api_uri(config) <> "/" <> api_version(config) <> uri
  defp hubic_auth_uri(config), do: config[:auth_uri]
  defp hubic_token_uri(config), do: config[:token_uri]
  defp hubic_api_uri(config), do: config[:api_uri]


end