defmodule Mix.Tasks.Ovh do
  @shortdoc "Create a new app and new credentials for accessing ovh api"
  @moduledoc ~S"""
  A mix task that generates the ex_ovh application secrets on the user's behalf.

  ## Steps

  - The user needs to set up an ovh account at https://www.ovh.co.uk/ and retrieve a username (nic-handle) and password.

  - Then the user is prompted to do some activations.

  - Upon completion of activations, the user needs to create an application in the ovh website.

  - Then the user can create an application at `https://eu.api.ovh.com/createApp/` or
    alternatively the user can use this mix task to generate the application:

  ## Examples

  Create an app with access to all apis:

      mix ovh \
      --login=<username> \
      --password=<password> \
      --appname='ex_ovh'

  Output:

      config :ex_ovh,
        ovh: %{
          application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
          application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
          consumer_key: System.get_env("EX_OVH_CONSUMER_KEY"),
          endpoint: System.get_env("EX_OVH_ENDPOINT"),
          api_version: System.get_env("EX_OVH_API_VERSION") || "1.0",
          connect_timeout: 30000, # 30 seconds
          connect_timeout: (60000 * 30) # 30 minutes
        }


  Create an app with access to all apis with specific app name and description:

      mix ovh \
      --login=<username> \
      --password=<password> \
      --appdescription='my app for api' \
      --endpoint='ovh-eu' \
      --apiversion='1.0' \
      --redirect_uri='http://localhost:4000/' \
      --accessrules='get-[/*]::put-[/me,/cdn]::post-[/me,/cdn]::delete-[]' \
      --appname='my_app'

  Output:

      config :my_app, MyApp.ExOvh,
          ovh: %{
            application_key: System.get_env("MY_APP_EX_OVH_APPLICATION_KEY"),
            application_secret: System.get_env("MY_APP_EX_OVH_APPLICATION_SECRET"),
            consumer_key: System.get_env("MY_APP_EX_OVH_CONSUMER_KEY"),
            endpoint: System.get_env("MY_APP_EX_OVH_ENDPOINT"),
            api_version: System.get_env("MY_APP_EX_OVH_API_VERSION") || "1.0",
            connect_timeout: 30000, # 30 seconds
            connect_timeout: (60000 * 30) # 30 minutes
          }

  ## Notes

  - Access rules: The default for access rules will give your ovh application access to *all* of the api calls. More
  than likely this is not a good idea. To limit the number of api endpoints available, generate access rules using
  the commandline arguments as seen in the example above.
  """
  use Mix.Task
  alias ExOvh.Utils
  alias ExOvh.Defaults


  @default_headers [{"Content-Type", "application/json; charset=utf-8"}]
  @default_options [ timeout: 30000, recv_timeout: (60000 * 1) ]


  # Public


  def run(args) do
    opts_map = parse_args(args)
    IO.inspect(opts_map, pretty: :true)
    Mix.Shell.IO.info("")
    Mix.Shell.IO.info("The details in the map above will be used to create the ovh application.")
    Mix.Shell.IO.info("")
    if Mix.Shell.IO.yes?("Do you want to proceed?") do
      HTTPoison.start
      opts_map = parse_args(args)

      message = get_credentials(opts_map)
      |> remove_private()
      |> create_or_update_env_file()
      |> print_config()

      Mix.Shell.IO.info(message)
      Mix.Shell.IO.info("")
      Mix.Shell.IO.info("Update your environment variables and your set.")
      Mix.Shell.IO.info("")
      Mix.Shell.IO.info("For example: ")
      Mix.Shell.IO.info("")
      Mix.Shell.IO.info("source .env")
    end
  end


  ##########################
  # Private
  #########################


  defp parse_args(args) do
    {opts, _, _} = OptionParser.parse(args)
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
    |> parsers_client_name()
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
    client_name = Keyword.get(opts, :appname, :ex_ovh)
    if client_name === :nil do
      raise "Task requires appname argument"
    end
    {opts, %{}}
  end


  defp parsers_login({opts, acc}), do: {opts, Map.merge(acc, %{login: Keyword.fetch!(opts, :login)}) }
  defp parsers_password({opts, acc}), do: {opts, Map.merge(acc, %{ password: Keyword.fetch!(opts, :password)}) }
  defp parsers_client_name({opts, acc}), do: {opts, Map.merge(acc, %{ client_name: Keyword.fetch!(opts, :appname)}) }
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
    {opts, Map.merge(acc, %{ redirect_uri: redirect_uri }) }
  end
  defp parsers_app_name({opts, acc}) do
    application_name = Keyword.get(opts, :appname, :nil)
    if application_name === :nil do
      application_name = "ex_ovh"
    end
    {opts, Map.merge(acc, %{ application_name: application_name }) }
  end
  defp parsers_app_desc({opts, acc}) do
    application_description = Keyword.get(opts, :appdescription, :nil)
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
    Og.context(__ENV__, :debug)

    method = :get
    uri = opts_map[:endpoint] <> Defaults.create_app_uri_suffix()
    body = ""
    headers = []
    options = @default_options
    resp = HTTPoison.request!(method, uri, body, headers, options)
    Map.get(resp, :body)
  end


  defp get_create_app_inputs(resp_body) do
    Og.context(__ENV__, :debug)

    inputs = Floki.find(resp_body, "form input")
    |> List.flatten()
    if Enum.any?(inputs, fn(input) -> input === [] end), do: raise "Empty input found"
    inputs
  end


  defp build_app_request(inputs, %{login: login, password: password} = opts_map) do
    Og.context(__ENV__, :debug)

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
    Og.context(__ENV__, :debug)

    method = :post
    uri = opts_map[:endpoint] <> "createApp/"
    body = req_body
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    options = @default_options
    resp = HTTPoison.request!(method, uri, body, headers, options)

    # Error checking
    cond do
     String.contains?(resp.body, msg = "There is already an application with that name for that Account ID") ->
      raise(msg <> ", try removing the old application first using the ovh api console or just create a new one.")
     String.contains?(resp.body, msg = "Invalid account/password") ->
      raise(msg <> ", try adding '-ovh' to the end of the login")
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
  defp extract(body) do
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
    Og.context(__ENV__, :debug)

    method = :post
    uri = opts_map[:endpoint] <> opts_map[:api_version] <> Defaults.consumer_key_suffix()
    body = %{ accessRules: access_rules, redirection: redirect_uri } |> Poison.encode!()
    headers = Map.merge(Enum.into(@default_headers, %{}), Enum.into([{"X-Ovh-Application", opts_map[:application_key]}], %{})) |> Enum.into([])
    options = @default_options
    resp = HTTPoison.request!(method, uri, body, headers, options)

    body = Poison.decode!(Map.get(resp, :body))
    {Map.get(body, "consumerKey"), Map.get(body, "validationUrl")}
  end


  defp bind_consumer_key_to_app({ck, validation_url}, opts_map) do
    Og.context(__ENV__, :debug)

    method = :get
    uri = validation_url
    body = ""
    headers = []
    options = @default_options
    resp = HTTPoison.request!(method, uri, body, headers, options)

    Map.get(resp, :body)
    |> get_bind_ck_to_app_inputs()
    |> build_ck_binding_request(opts_map)
    |> send_ck_binding_request(validation_url, ck)
  end


  defp get_bind_ck_to_app_inputs(resp_body) do
    Og.context(__ENV__, :debug)

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
    Og.context(__ENV__, :debug)

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
    Og.context(__ENV__, :debug)

    method = :post
    uri = validation_url
    body = req_body
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    options = @default_options
    resp = HTTPoison.request!(method, uri, body, headers, options)

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
    Og.context(__ENV__, :debug)

    create_app_body = get_app_create_page(opts_map) |> get_create_app_inputs() |> build_app_request(opts_map) |> send_app_request(opts_map)
    opts_map = Map.merge(opts_map, %{
      application_key: get_application_key(create_app_body),
      application_secret: get_application_secret(create_app_body),
      application_name: get_application_name(create_app_body),
      application_description: get_application_description(create_app_body)
    })
    ck = get_consumer_key(opts_map) |> bind_consumer_key_to_app(opts_map)
    Map.merge(opts_map, %{ consumer_key: ck })
    |> Map.delete(:login) |> Map.delete(:password)
  end


  defp remove_private(opts_map) do
    opts_map |> Map.delete(:login) |> Map.delete(:password)
  end


  defp config_names(client_name) do
    Og.context(__ENV__, :debug)

    {config_header, mod_client_name} =
    case client_name  do
      "ex_ovh" ->
        {
          ":" <> client_name,
          "EX_OVH_"
        }
      other ->
        {
          ":" <> client_name <> ", " <> Macro.camelize(client_name) <> "." <> "ExOvh",
          String.upcase(other) <> "_EX_OVH_"
        }
    end
    {config_header, mod_client_name}
  end

  defp create_or_update_env_file(options) do
    env_path = ".env"
    File.touch!(env_path)
    existing = File.read!(env_path)
    {_config_header, mod_client_name} = config_names(options.client_name)
    format_date = ExOvh.Utils.formatted_date()
    new = existing <>
    ~s"""

    # updated on #{format_date}
    export #{mod_client_name <> "APPLICATION_KEY"}=\"#{options.application_key}\"
    export #{mod_client_name <> "APPLICATION_SECRET"}="#{options.application_secret}\"
    export #{mod_client_name <> "CONSUMER_KEY"}="#{options.consumer_key}\"
    export #{mod_client_name <> "ENDPOINT"}=\"#{options.endpoint}\"
    export #{mod_client_name <> "API_VERSION"}=\"#{options.api_version}\"

    """
    {:ok, file} = File.open(env_path, [:write, :utf8])
    IO.binwrite(file, new)
    File.close(file)
    options
  end


  defp print_config(options) do
    Og.context(__ENV__, :debug)

    client_name = options.client_name
    {config_header, mod_client_name} = config_names(client_name)

    ~s"""

    Add the following paragraph to your config.exs file(s):

    config #{config_header},
        ovh: %{
          application_key: System.get_env(\"#{mod_client_name <> "APPLICATION_KEY"}\"),
          application_secret: System.get_env(\"#{mod_client_name <> "APPLICATION_SECRET"}\"),
          consumer_key: System.get_env(\"#{mod_client_name <> "CONSUMER_KEY"}\"),
          endpoint: System.get_env(\"#{mod_client_name <> "ENDPOINT"}\"),
          api_version: System.get_env(\"#{mod_client_name <> "API_VERSION"}\") || "1.0",
          connect_timeout: 30000, # 30 seconds
          connect_timeout: (60000 * 30) # 30 minutes
        }
    """
  end


end