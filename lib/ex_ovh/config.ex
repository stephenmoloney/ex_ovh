defmodule ExOvh.Config do
  @moduledoc :false
  @default_hackney_opts [connect_timeout: 8000, recv_timeout: 5000]
  alias ExOvh.Defaults

  @doc "Starts an agent for the storage of credentials in memory"
  def start_agent(client, opts) do
    Og.context(__ENV__, :debug)
    otp_app = Keyword.get(opts, :otp_app, :false) || Og.log_return(__ENV__, :error) |> raise()
    Agent.start_link(fn -> config(client, otp_app) end, name: agent_name(client))
  end

  @doc "Gets all the config.exs environment variables"
  def get_config_from_env(client, otp_app) do
    config = Application.get_env(otp_app, client)
    case otp_app do
      :ex_ovh -> Application.get_all_env(otp_app)
      _ ->
        case config do
          :nil ->
            temp_client = Module.split(client) |> List.delete_at(-1) |> Enum.join(".") |> String.to_atom()
            temp_client = Module.concat(Elixir, temp_client)
            Application.get_env(otp_app, temp_client)
          config -> config
        end
    end
  end

  @doc "Gets the httpoison config.exs environment variables"
  def get_ovh_config_from_env(client, otp_app) do
    try do
      get_config_from_env(client, otp_app) |> Keyword.fetch!(:ovh)
      |> Keyword.merge(Defaults.ovh(), fn(k, v1, v2) ->
        case {k, v1} do
          {_, :nil} -> v2
          {:endpoint, v1} -> Defaults.endpoints()[v1]
          _ -> v1
        end
      end)
    rescue
      _error -> Og.log_return("No ovh_config was found. ",  __ENV__, :warn) |> raise()
    end
  end

  @doc "Gets the httpoison config.exs environment variables"
  def get_hackney_opts_from_env(client, otp_app) do
    try do
      get_config_from_env(client, otp_app) |> Keyword.fetch!(:hackney)
    rescue
      _error ->
        Og.log_return("No hackney_opts was found. " <>
                      "Falling back to default httpoison settings #{inspect(@default_hackney_opts)}", __ENV__, :warn)
        @default_hackney_opts
    end
  end

  @doc "Gets all the config variables from a supervised Agent"
  def config(client) do
    Agent.get(agent_name(client), fn(config) -> config end)
  end

  @doc "Gets the ovh related config variables from a supervised Agent"
  def ovh_config(client) do
    Agent.get(agent_name(client), fn(config) -> config[:ovh] end)
  end

  @doc "Gets the hackney_opts related config variables from a supervised Agent"
  def hackney_opts(client) do
    Agent.get(agent_name(client), fn(config) -> config[:hackney] end)
  end

  @doc "Gets the diff"
  def get_diff(client) do
    Agent.get(agent_name(client), fn(config) -> config[:ovh][:diff] end)
  end

  defp config(client, otp_app) do
    diff = calculate_diff(client, otp_app)
    ovh_config = get_ovh_config_from_env(client, otp_app)
    |> Keyword.put(:diff, diff)

    hackney_opts = get_hackney_opts_from_env(client, otp_app)
    connect_timeout = hackney_opts[:connect_timeout] || 30000 # 30 seconds
    recv_timeout = hackney_opts[:recv_timeout] || (60000 * 30) # 30 minutes

    [
    ovh: ovh_config,
    httpoison:
            [
            timeout: connect_timeout,
            recv_timeout: recv_timeout,
            ]
    ]
  end

  defp agent_name(client) do
    Module.concat(__MODULE__, client)
  end

  defp calculate_diff(client, otp_app) do
    api_time = api_time_request(client, otp_app)
    os_t = :os.system_time(:seconds)
    os_t - api_time
  end

  defp api_time_request(client, otp_app) do
    ovh_config = get_ovh_config_from_env(client, otp_app)
    method = :get
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> "/auth/time"
    body = ""
    headers = [{"Content-Type", "application/json; charset=utf-8"}]
    options = get_hackney_opts_from_env(client, otp_app)
    {:ok, resp} = :hackney.request(method, uri, headers, body, options)
    Poison.decode!(resp.body)
  end

end






