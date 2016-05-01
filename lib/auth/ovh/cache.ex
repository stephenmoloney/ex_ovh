defmodule ExOvh.Auth.Ovh.Cache do
  @moduledoc :false
  use GenServer
  import ExOvh.Utils, only: [gen_server_name: 1]
  alias ExOvh.Utils


  # Public


  def start_link({client, ovh_config, opts}) do
    Og.context(__ENV__, :debug)
    GenServer.start_link(__MODULE__, {client, ovh_config}, [name: gen_server_name(client)])
  end


  @doc "Retrieves the ovh api time diff from the state"
  def get_time_diff(client) do
    GenServer.call(gen_server_name(client), :get_diff)
  end
  @doc "Retrieves the ovh config map"
  def get_ovh_config(client) do
    GenServer.call(gen_server_name(client), :get_config)
  end


  # Genserver Callbacks


  def init({client, ovh_config}) do
    Og.context(__ENV__, :debug)
    diff = calculate_diff(client, ovh_config)
    {:ok, {ovh_config, diff}}
  end

  def handle_call(:get_diff, _from, {ovh_config, diff}) do
    Og.context(__ENV__, :debug)
    {:reply, diff, {ovh_config, diff}}
  end

  def handle_call(:get_config, _from, {ovh_config, diff}) do
    Og.context(__ENV__, :debug)
    {:reply, ovh_config, {ovh_config, diff}}
  end

  def handle_cast({:set_diff, new_diff}, {ovh_config, diff}) do
    Og.context(__ENV__, :debug)
    {:noreply, {ovh_config, new_diff}}
  end

  def terminate(:shutdown, state) do
    Og.context(__ENV__, :warn)
    Og.log_return("gen_server #{__MODULE__} shutting down", :warn)
    :ok
  end


  # Private


  defp api_time_request(client, ovh_config) do
    Og.context(__ENV__, :debug)
    method = :get
    uri = ovh_config[:endpoint] <> ovh_config[:api_version] <> "/auth/time"
    body = ""
    headers = [{"Content-Type", "application/json; charset=utf-8"}]
    httpoison_config = client.httpoison_config()
    options = httpoison_config
    resp = HTTPoison.request!(method, uri, body, headers, options)
    api_time = Poison.decode!(resp.body)
  end


  defp calculate_diff(client, ovh_config) do
    api_time = api_time_request(client, ovh_config)
    os_t = :os.system_time(:seconds)
    os_t - api_time
  end


  #Caches the ovh api time diff
  defp set_time_diff(client) do
    ovh_config = get_config(client)
    set_time_diff(client, ovh_config)
  end
  defp set_time_diff(client, ovh_config) when is_list(ovh_config) do
    diff = calculate_diff(client, ovh_config)
    GenServer.cast(gen_server_name(client), {:set_diff, diff})
  end


end