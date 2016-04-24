defmodule ExOvh.Utils do
  @moduledoc false

  alias ExOvh.Auth.Ovh.Cache
  alias ExOvh.Defaults


  @doc """
  For naming a supervisor to incorporate the name of the client.

  The client name is required so that when a client makes a request, the correct supervisor
  is called if there are multiple clients in use.
  """
  defmacro supervisor_name(client) do
    caller = __CALLER__.module
    quote do
      (
        (
         Atom.to_string(unquote(client))
         <>
         "."
         )
         <>
         Atom.to_string(unquote(caller))
       )
       |> String.replace("Elixir.", "")
       |> String.to_atom()
     end
  end


  @doc """
  For naming a genserver to incorporate the name of the client.

  The client name is required so that when a client makes a request, the correct genserver
  is called if there are multiple clients in use.
  """
  defmacro gen_server_name(client) do
    caller = __CALLER__.module
    quote do
      (
        (
         Atom.to_string(unquote(client))
         <>
         "."
         )
         <>
         Atom.to_string(unquote(caller))
      )
      |> String.replace("Elixir.", "")
      |> String.to_atom()
    end
  end


  @doc """
  For naming an ets table to incorporate the name of the client.

  The client name is required so that when a client makes a request, the correct ets table
  is looked up if there are multiple clients in use.
  """
  defmacro ets_tablename(client) do
    # caller = __CALLER__.module
    quote do
      "Ets."
      <>
      (
        gen_server_name(unquote(client))
        |> Atom.to_string()
      )
      |> String.to_atom()
    end
  end

  @doc """
  Changes the timeout option for a http_query.
  """
  @spec change_http_query_timeout(Openstex.HttpQuery.t, integer) :: Openstex.HttpQuery.t
  def change_http_query_timeout(%Openstex.HttpQuery{options: options} = http_query, new_timeout) do
    new_options = Map.merge(options, Map.put(options, :timeout, new_timeout))
    Map.put(http_query, :options, new_options)
  end


  @doc """
  Returns a string with the formatted date
  """
  @spec formatted_date() :: String.t
  def formatted_date() do
    {year, month, date} = :erlang.date()
    Integer.to_string(date) <> "." <>
    Integer.to_string(month) <> "." <>
    Integer.to_string(year)
  end


  def config(client), do: Cache.get_config(client)
  def endpoints(), do: Defaults.endpoints()
  def endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  def api_version(config), do: config[:api_version]
  def uri(uri, config), do: endpoint(config) <> api_version(config) <> uri
  def app_secret(config), do: config[:application_secret]
  def app_key(config), do: config[:application_key]
  def get_consumer_key(config), do: config[:consumer_key]
  def connect_timeout(config), do: config[:connect_timeout]
  def receive_timeout(config), do: config[:receive_timeout]
  def set_opts(opts, config), do: Keyword.merge([ timeout: connect_timeout(config), recv_timeout: receive_timeout(config) ], opts)
  def access_rules(), do: Defaults.access_rules()
  def access_rules(config), do: config[:access_rules]
  def default_create_app_uri(config), do: endpoint(config) <> "createApp/"
  def consumer_key_uri(config), do: endpoint(config) <> api_version(config) <> "/auth/credential/"


end
