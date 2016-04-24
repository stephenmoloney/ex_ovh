defmodule ExOvh.Auth.Ovh.Cache do
  @moduledoc :false
  use GenServer
  import ExOvh.Utils, only: [gen_server_name: 1]
  alias ExOvh.Utils


  # Public


  def start_link({client, config, opts}) do
    Og.context(__ENV__, :debug)
    client
    |> Og.log_return(__ENV__, :warn)
    GenServer.start_link(__MODULE__, {client, config, opts}, [name: gen_server_name(client)])
  end


  @doc "Retrieves the ovh api time diff from the state"
  def get_time_diff(client) do
    client |> Og.log_return(__ENV__, :warn)
    gen_server_name(client) |> Og.log_return(__ENV__, :warn)

    GenServer.call(gen_server_name(client), :get_diff)
  end
  @doc "Retrieves the ovh config map"
  def get_config(client) do
    client |> Og.log_return(__ENV__, :warn)
    gen_server_name(client) |> Og.log_return(__ENV__, :warn)

    GenServer.call(gen_server_name(client), :get_config)
  end


  # Genserver Callbacks


  def init({client, config, opts}) do
    Og.context(__ENV__, :debug)
    diff = calculate_diff(config)
    {:ok, {config, diff}}
  end

  def handle_call(:get_diff, _from, {config, diff}) do
    Og.context(__ENV__, :debug)
    {:reply, diff, {config, diff}}
  end

  def handle_call(:get_config, _from, {config, diff}) do
    Og.context(__ENV__, :debug)
    {:reply, config, {config, diff}}
  end

  def handle_cast({:set_diff, new_diff}, {config, diff}) do
    Og.context(__ENV__, :debug)
    {:noreply, {config, new_diff}}
  end

  def terminate(:shutdown, state) do
    Og.context(__ENV__, :warn)
    Og.log_return("gen_server #{__MODULE__} shutting down", :warn)
    :ok
  end


  # Private


  defp api_time_request(config) do
    method = :get
    uri = Utils.endpoint(config) <> Utils.api_version(config) <> "/auth/time"
    body = ""
    headers = [{"Content-Type", "application/json; charset=utf-8"}]
    options = Utils.set_opts([], config)
    resp = HTTPoison.request!(method, uri, body, headers, options)
    api_time = Poison.decode!(resp.body)
  end


  defp calculate_diff(config) do
    api_time = api_time_request(config)
    os_t = :os.system_time(:seconds)
    os_t - api_time
  end


  #Caches the ovh api time diff
  defp set_time_diff(client) do
    config = get_config(client)
    set_time_diff(client, config)
  end
  defp set_time_diff(client, config) when is_map(config) do
    diff = calculate_diff(config)
    GenServer.cast(gen_server_name(client), {:set_diff, diff})
  end


end