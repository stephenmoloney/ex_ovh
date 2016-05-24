defmodule ExOvh.Cache do
  @moduledoc :false # Stores the time diff in state of the gen_server - later used in authentication headers for every request
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
    diff = calculate_diff(client)
    {:ok, diff}
  end

  def handle_call(:get_diff, _from, diff) do
    {:reply, diff, diff}
  end

  def terminate(:shutdown, _state) do
    Og.log_return("gen_server #{__MODULE__} shutting down", __ENV__, :warn)
    :ok
  end


  # Private


  defp calculate_diff(client) do
    api_time = api_time_request(client)
    os_t = :os.system_time(:seconds)
    os_t - api_time
  end


  defp api_time_request(client) do
    ovh_config = client.ovh_config()
    method = :get
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> "/auth/time"
    body = ""
    headers = [{"Content-Type", "application/json; charset=utf-8"}]
    client
    httpoison_opts = client.httpoison_config()
    options = httpoison_opts
    resp = HTTPoison.request!(method, uri, body, headers, options)
    Poison.decode!(resp.body)
  end


end