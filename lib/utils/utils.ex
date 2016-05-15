defmodule ExOvh.Utils do
  @moduledoc false
  alias ExOvh.Auth.Ovh.Cache, as: OvhCache
  alias ExOvh.Auth.Openstack.Swift.Cache, as: SwiftCache
  alias ExOvh.Ovh.Defaults


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
