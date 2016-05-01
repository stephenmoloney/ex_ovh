defmodule ExOvh.Utils do
  @moduledoc false

  alias ExOvh.Auth.Ovh.Cache, as: OvhCache
  alias ExOvh.Auth.Openstack.Swift.Cache, as: SwiftCache
  alias ExOvh.Ovh.Defaults


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
        unquote(client) |> Atom.to_string()
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


end
