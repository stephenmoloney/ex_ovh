defmodule ExOvh.Auth.Ovh.Cache do
  # Stores the time diff in state of the gen_server - later used in authentication headers for every request
  @moduledoc :false
  use GenServer


  # Public


  def start_link(client) do
    Og.context(__ENV__, :debug)
    GenServer.start_link(__MODULE__, client, [name: client])
  end


  @doc "Retrieves the ovh api time diff from the state"
  def get_time_diff(client) do
    GenServer.call(client, :get_diff)
  end


  # Genserver Callbacks


  def init(client) do
    Og.context(__ENV__, :debug)
    diff = calculate_diff(client)
    |> Og.log_return(:error)
    {:ok, diff}
  end

  def handle_call(:get_diff, _from, diff) do
    Og.context(__ENV__, :debug)
    {:reply, diff, diff}
    |> Og.log_return(__ENV__, :warn)
  end

  def terminate(:shutdown, state) do
    Og.context(__ENV__, :warn)
    Og.log_return("gen_server #{__MODULE__} shutting down", :warn)
    :ok
  end


  # Private


  defp calculate_diff(client) do
    Og.context(__ENV__, :debug)
    api_time = api_time_request(client)
    os_t = :os.system_time(:seconds)
    os_t - api_time
  end


  defp api_time_request(client) do
    Og.context(__ENV__, :debug)
    client |> Og.log_return(__ENV__)
    ovh_config = client.config() |> Og.log_return(__ENV__)
    method = :get
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> "/auth/time"
    body = ""
    headers = [{"Content-Type", "application/json; charset=utf-8"}]
    client |> Og.log_return(__ENV__)
    httpoison_opts = client.httpoison_config()
    options = httpoison_opts
    {method, uri, body, headers, options} |> Og.log_return(__ENV__, :warn)
    resp = HTTPoison.request!(method, uri, body, headers, options)
    api_time = Poison.decode!(resp.body)
  end


end