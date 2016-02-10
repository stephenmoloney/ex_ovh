defmodule Mix.Tasks.Ovh do
  use Mix.Task
  alias ExOvh.Ovh.Defaults
  alias ExOvh.Ovh.Auth

  @shortdoc "Create a new app and new credentials for accessing ovh api"
  @default_headers ["Content-Type": "application/json; charset=utf-8"]
  @timeout 10_000

  defp endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  defp access_rules(config), do: config[:access_rules]
  defp api_version(config), do: config[:api_version]
  defp app_secret(config), do: config[:application_secret]
  defp app_key(config), do: config[:application_key]
  defp default_create_app_uri(config), do: endpoint(config) <> "createApp/"
  defp consumer_key_uri(config), do: endpoint(config) <> api_version(config) <> "/auth/credential/"


  ##########################
  # Public
  #########################


  def run(args) do
    opts_map = parse_args(args)
    IO.inspect(opts_map, pretty: :true)
    Mix.Shell.IO.info("")
    Mix.Shell.IO.info("The details in the map above will be used to create the ovh application.")
    Mix.Shell.IO.info("")
    if Mix.Shell.IO.yes?("Do you want to proceed?") do
      Application.start(:ibrowse, :permanent)
      Application.start(:httpotion, :permanent)
      opts_map = parse_args(args)
      options = get_credentials(opts_map)
      message = "
      %{
        application_key: \"#{options.application_key}\",
        application_secret: \"#{options.application_secret}\",
        consumer_key: \"#{options.consumer_key}\",
        endpoint: \"#{options.endpoint}\",
        api_version: \"#{options.api_version}\"
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
    {opts, opts_map } = opts
    |> has_required_args()
    |> parsers_login()
    |> parsers_password()
    |> parsers_endpoint()
    |> parsers_api_version()
    |> parsers_redirect_uri()
    |> parsers_app_name()
    |> parsers_app_desc()
    |> parsers_access_rules()
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
    {opts, %{}}
  end


  defp parsers_login({opts, acc}), do: {opts, Map.merge(acc, %{login: Keyword.fetch!(opts, :login)}) }
  defp parsers_password({opts, acc}), do: {opts, Map.merge(acc, %{ password: Keyword.fetch!(opts, :password)}) }
  defp parsers_endpoint({opts, acc}) do
    endpoint = Keyword.get(opts, :endpoint, :nil)
    if endpoint === :nil do
      endpoint = "ovh-eu"
    end
    {opts, Map.merge(acc, %{ endpoint: endpoint }) }
  end
  defp parsers_api_version({opts, acc}) do
    api_version = Keyword.get(opts, :apiversion, :nil)
    if api_version === :nil do
      api_version = "1.0"
    end
    {opts, Map.merge(acc, %{ api_version: api_version }) }
  end
  defp parsers_redirect_uri({opts, acc}) do
    redirect_uri = Keyword.get(opts, :redirecturi, :nil)
    if redirect_uri === :nil do
      redirect_uri = ""
    end
    {opts, Map.merge(acc, %{ redirecturi: redirect_uri }) }
  end
  defp parsers_app_name({opts, acc}) do
    application_name = Keyword.get(opts, :appname, :nil)
    if application_name === :nil do
      application_name = "ex_ovh"
    end
    {opts, Map.merge(acc, %{ application_name: application_name }) }
  end
  defp parsers_app_desc({opts, acc}) do
    application_description = Keyword.get(opts, :appdesc, :nil)
    if application_description === :nil do
      application_description = "ex_ovh"
    end
    {opts, Map.merge(acc, %{ application_description: application_description }) }
  end
  defp parsers_access_rules({opts, acc}) do
    access_rules = Keyword.get(opts, :accessrules, :nil)
    if access_rules === :nil do
      access_rules = Defaults.access_rules()
    else
      access_rules = access_rules
      |> String.split("::")
      |> Enum.map(fn(method_rules) ->
        [method, paths] = String.split(method_rules, "-")
        {method, paths}
      end)
      |> Enum.reduce([], fn({method, concat_paths}, acc) ->
        paths = concat_paths
        |> String.lstrip(?[)
        |> String.strip(?]) #rstrip has a bug but fixed in master (01/02/2016)
        |> String.split(",")
        new_rules = Enum.filter_map(paths,
          fn(path) -> path !== "" end,
          fn(path) ->
          %{
            method: String.upcase(method),
            path: path
           }
        end)
        List.insert_at(acc, -1, new_rules)
      end)
      |> List.flatten()
      end
    {opts, Map.merge(acc, %{access_rules: access_rules}) }
  end


  defp get_app_create_page(opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    options = [ timeout: @timeout ]
    default_create_app_uri(opts_map)
    %HTTPotion.Response{body: resp_body, headers: headers, status_code: status_code} =
      HTTPotion.request(:get, default_create_app_uri(opts_map), options)
    resp_body
  end


  defp get_create_app_inputs(resp_body) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    inputs = Floki.find(resp_body, "form input")
    |> List.flatten()
    if Enum.any?(inputs, fn(input) -> input === [] end), do: raise "Empty input found"
    inputs
  end


  defp build_app_request(inputs, %{login: login, password: password} = opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {acc, _index, _max} =
    Enum.reduce(inputs, {"", 1, Enum.count(inputs)}, fn({"input", input, _}, acc) ->
      name = :proplists.get_value("name", input)
      value = ""
      case name do
        "nic" ->
          value = login
        "password" ->
          value = password
        "applicationName" ->
          value = opts_map.application_name
         "applicationDescription" ->
          value = opts_map.application_description
        _ ->
          raise "Unexpected input"
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
    acc
  end


  defp send_app_request(req_body, opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    uri = Defaults.endpoints()[opts_map.endpoint] <> "createApp/"
    resp = HTTPotion.request(:post, uri, [body: req_body, headers: ["Content-Type": "application/x-www-form-urlencoded"]])
    error_msg1 = "There is already an application with that name for that Account ID"
    cond do
     String.contains?(resp.body, error_msg1) ->
      raise error_msg1
     String.contains?(resp.body, "Application created") ->
      resp.body
     true ->
      raise "unknown error"
    end
  end


  defp get_application_secret(body), do: Map.get(extract(body), "secret")
  defp get_application_key(body), do: Map.get(extract(body), "key")
  defp get_application_name(body), do: Map.get(extract(body), "name")
  defp get_application_description(body), do: Map.get(extract(body), "description")
  def extract(body) do
    Floki.find(body, "pre")
    |> Enum.map(fn({"pre", [], [val]}) -> val end)
    |> Enum.map(fn(ext) ->
        case ext do
          {key, _, [val]} ->
            {key, val}
          val when is_binary(val) ->
            if String.length(val) > 20 do
              {"secret", val}
            else
              {"key", val}
            end
        end
      end)
    |> Enum.into(%{})
  end


  defp get_consumer_key(%{access_rules: access_rules, redirect_uri: redirect_uri} = opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    body = %{ accessRules: access_rules, redirection: redirect_uri }
    query = {:post, consumer_key_uri(opts_map), body}
    {method, uri, options} = Auth.ovh_prepare_request(opts_map, query)
    options = Map.put(options, :headers, Map.merge(@default_headers, %{ "X-Ovh-Application": app_key(opts_map)}))
    body = HTTPotion.request(method, consumer_key_uri(opts_map), options) |> Map.get(:body) |> Poison.decode!()
    {Map.get(body, "consumerKey"), Map.get(body, "validationUrl")}
  end


  defp bind_consumer_key_to_app({ck, validation_url}, opts_map) do
      HTTPotion.request(:get, validation_url) |> Map.get(:body)
      |> get_bind_ck_to_app_inputs()
      |> build_ck_binding_request(opts_map)
      |> send_ck_binding_request(validation_url, ck)
  end


  defp get_bind_ck_to_app_inputs(resp_body) do
    inputs = Floki.find(resp_body, "form input") ++
    Floki.find(resp_body, "form select")
    |> List.flatten()
    |> Enum.filter(fn({type, input, options}) ->
      :proplists.get_value("name", input) !== "identifiant"
    end)
    if Enum.any?(inputs, fn(input) -> input === [] end), do: raise "Inputs should not be empty"
    inputs
  end


  defp build_ck_binding_request(inputs, %{login: login, password: password} = opts_map) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    {acc, _index, _max} =
    Enum.reduce(inputs, {"", 1, Enum.count(inputs)}, fn({type, input, options}, acc) ->
      {name_val, value} =
      cond do
        type == "input" &&  {"name", "credentialToken"} in input ->
          name_val = :proplists.get_value("name", input)
          value = :proplists.get_value("value", input)
          {name_val, value}
        type == "input" && {"type", "password"} in input && {"placeholder", "Password"} in input ->
          name_val = :proplists.get_value("name", input)
          value = password
          {name_val, value}
        type == "input" && {"type", "text"} in input && {"placeholder", "Account ID"} in input ->
          name_val = :proplists.get_value("name", input)
          value = login
          {name_val, value}
        type == "select" && {"name", "duration"} in input ->
          name_val = :proplists.get_value("name", input)
          value = "0"
          {name_val, value}
        true ->
          raise "Unexpected input"
      end
      param =  name_val <> "=" <> value
      {acc, index, max} = acc
      if index === max do
        acc = acc <> param
      else
        acc = acc <> param <> "&"
      end
      {acc, index + 1, max}
    end)
    acc
  end


  defp send_ck_binding_request(req_body, validation_url, ck) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    resp = HTTPotion.request(:post, validation_url, [body: req_body, headers: ["Content-Type": "application/x-www-form-urlencoded"]])
    error_msg1 = "Failed to bind the consumer token to the application. Please try to validate the consumer token manually at #{validation_url}"
    error_msg2 = "Invalid validity period entered for the consumer token. Please try to validate the consumer token manually at #{validation_url}"
    cond do
     String.contains?(resp.body, "Invalid validity") ->
      raise error_msg2
     String.contains?(resp.body, "Your token is now valid, you can use it in your application") ->
      ck
     true ->
      raise error_msg1
    end
  end


  defp get_credentials(opts_map) do
    create_app_body = get_app_create_page(opts_map) |> get_create_app_inputs() |> build_app_request(opts_map) |> send_app_request(opts_map)
    opts_map = Map.merge(opts_map, %{
      application_key: get_application_key(create_app_body),
      application_secret: get_application_secret(create_app_body),
      application_name: get_application_name(create_app_body),
      application_description: get_application_description(create_app_body)
    })
    ck = get_consumer_key(opts_map) |> bind_consumer_key_to_app(opts_map)
    Map.merge(opts_map, %{consumer_key: ck,})
    |> Map.delete(:login) |> Map.delete(:password)
  end


end