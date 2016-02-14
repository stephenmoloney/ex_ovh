defmodule Mix.Tasks.Hubic do
  @moduledoc ~S"""
  Gets the access and refresh token for access the hubic api
  and returns them as a map to assist setting up the
  configuration file `secret.prod.exs`
  """
  use Mix.Task
  alias ExOvh.Hubic.Defaults
  @hubic_auth_uri Defaults.hubic()[:auth_uri]
  @hubic_token_uri Defaults.hubic()[:token_uri]
  @timeout 20_000


  ##########################
  # Public
  #########################


  def run(args) do
    LoggingUtils.log_return(args, :debug)
    opts_map = parse_args(args)
    LoggingUtils.log_return(opts_map, :debug)
    IO.inspect(opts_map, pretty: :true)
    Mix.Shell.IO.info("")
    Mix.Shell.IO.info("The details in the map above will be used to get the hubic refresh token.")
    Mix.Shell.IO.info("")
    if Mix.Shell.IO.yes?("Do you want to proceed?") do
      Application.start(:ibrowse, :permanent)
      Application.start(:httpotion, :permanent)
      options = get_auth_code(opts_map) |> get_refresh_token() |> remove_private()
      message = "
      %{
        client_id: \"#{options.client_id}\",
        client_secret: \"#{options.client_secret}\",
        refresh_token: \"#{options.refresh_token}\",
        redirect_uri: \"#{options.redirect_uri}\"
       }
      "
      Mix.Shell.IO.info(message)
    end
  end


  ##########################
  # Private
  #########################


  defp parse_args(args) do
    {opts, _, _} = OptionParser.parse(args)
    LoggingUtils.log_return(opts, :debug)
    {opts, opts_map} = opts
    |> has_required_args()
    |> parsers_login()
    |> parsers_password()
    |> parsers_client_id()
    |> parsers_client_secret()
    |> parsers_redirect_uri()
    opts_map
  end

  defp has_required_args(opts) do
    login = Keyword.get(opts, :login, :nil)
    if login === :nil do
      raise "Task requires login argument"
    end
    password = Keyword.get(opts, :password, :nil)
    if password === :nil do
      raise "Task requires password argument"
    end
    client_id = Keyword.get(opts, :clientid, :nil)
    if client_id === :nil do
      raise "Task requires client_id argument"
    end
    client_secret = Keyword.get(opts, :clientsecret, :nil)
    if client_secret === :nil do
      raise "Task requires client_secret argument"
    end
    redirect_uri = Keyword.get(opts, :redirecturi, :nil)
    if redirect_uri === :nil do
      raise "Task requires redirect_uri argument"
    end
    {opts, %{}}
  end


  defp parsers_login({opts, acc}), do: {opts, Map.merge(acc, %{login: Keyword.fetch!(opts, :login)}) }
  defp parsers_password({opts, acc}), do: {opts, Map.merge(acc, %{ password: Keyword.fetch!(opts, :password)}) }
  defp parsers_client_id({opts, acc}), do: {opts, Map.merge(acc, %{ client_id: Keyword.fetch!(opts, :clientid)}) }
  defp parsers_client_secret({opts, acc}), do: {opts, Map.merge(acc, %{ client_secret: Keyword.fetch!(opts, :clientsecret)}) }
  defp parsers_redirect_uri({opts, acc}), do: {opts, Map.merge(acc, %{ redirect_uri: Keyword.fetch!(opts, :redirecturi)}) }


  # - Summary: Gets the authorisation code when the refresh token is not provided in config.exs by the user
  # - Makes a request to the @hubic_auth_uri with the client id and scopes for the code
  # - Autocompletes the form information to acquire the code
  # - Sends the application/x-www-form-urlencoded information to the @hubic_auth_uri on behalf of the user
  # - Parses and returns the authorisation code inside the opts_map
  defp get_auth_code(opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    query_string = "?client_id=" <> opts_map.client_id <>
                   "&redirect_uri=" <> URI.encode_www_form(opts_map.redirect_uri) <>
                   "&scope=" <> "usage.r,account.r,getAllLinks.r,credentials.r,sponsorCode.r,activate.w,sponsored.r,links.drw" <>
                   "&response_type=" <> "code" <>
                   "&state=" <> SecureRandom.urlsafe_base64(10)
    options = %{ timeout: @timeout }
    uri = @hubic_auth_uri <> query_string
    resp = HTTPotion.request(:get, uri, options)
    resp =
    %{
      body: resp.body,
      headers: resp.headers,
      status_code: resp.status_code
     }
    inputs = get_validated_inputs(resp.body)
    {req_body, _, _} = Enum.reduce(inputs, {"", 1, Enum.count(inputs)}, fn({"input", input, _}, acc) ->
      name = :proplists.get_value("name", input)
      value = ""
      {name, value} =
      case name do
        "login" ->
          value = opts_map.login
          {name, value}
        "user_pwd" ->
          value = opts_map.password
          {name, value}
        _ ->
          value = :proplists.get_value("value", input)
          {name, value}
      end
      param =  name <> "=" <> value
      {acc, index, max} = acc
      if index === max do
        acc = acc <> param
      else
        acc = acc <> param <> "&"
      end
      {acc, index + 1, max}
    end)

    req_body = req_body <> "&links=d" # bug fix: *delete links needed - unknown why not in inputs already*
    options = %{ body: req_body, headers: %{ "Content-Type": "application/x-www-form-urlencoded" } }
    resp = HTTPotion.request(:post, @hubic_auth_uri, options)

    if resp.status_code !== 302, do: raise Floki.find(resp.body, "h4.text-error") |> Floki.text

    resp =
    %{
      body: resp.body,
      headers: resp.headers  |> Enum.into(%{}),
      status_code: resp.status_code
    }

    code = resp.headers
    |> Map.get(:Location)
    |> URI.parse
    |> Map.get(:query)
    |> URI.decode_query
    |> Map.get("code")
    Map.merge(opts_map, %{ auth_code: code })
  end


  defp get_validated_inputs(resp_body) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    inputs = Floki.find(resp_body, "form input[type=text], form input[type=password], form input[type=checkbox], form input[type=hidden]")
    |> List.flatten()
    if Enum.any?(inputs, fn(input) -> input === [] end), do: raise "Empty input found"
    inputs
  end

  #- Adds the refresh_token to the opts_map
  @spec get_refresh_token(opts_map :: map) :: map
  def get_refresh_token(opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    auth_credentials = opts_map.client_id <> ":" <> opts_map.client_secret
    auth_credentials_base64 = Base.encode64(auth_credentials)
    req_body = "code=" <> opts_map.auth_code <>
               "&redirect_uri=" <> URI.encode_www_form(opts_map.redirect_uri) <>
               "&grant_type=authorization_code"
    headers = %{
               "Content-Type": "application/x-www-form-urlencoded",
               "Authorization": "Basic " <> auth_credentials_base64
              }
    options = %{ body: req_body, headers: headers, timeout: @timeout }
    resp = HTTPotion.request(:post, @hubic_token_uri, options)
    now_milli_seconds = :os.system_time(:milli_seconds)
    body =
    %{
      body: resp.body |> Poison.decode!(),
      headers: resp.headers,
      status_code: resp.status_code
    }
    |> Map.get(:body)
    if Map.has_key?(body, "error") do
      error = Map.get(resp, "error") <> " :: " <> Map.get(resp, "error_description")
      raise error
    end
    refresh_token = Map.get(body, "refresh_token")
    Map.merge(opts_map, %{ refresh_token: refresh_token })
  end


  defp remove_private(opts_map) do
    opts_map |> Map.delete(:login) |> Map.delete(:password) |> Map.delete(:auth_code)
  end


end



