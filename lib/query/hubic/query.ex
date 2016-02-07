defmodule ExOvh.Query.Hubic do
  @moduledoc ~s"""
    Helps to build queries for the hubic api.

    The raw query can be passed into a client request.

    ## Example

      `scope = ExOvh.hubic_request(ExOvh.Query.Hubic.scope())`
  """

  @doc """
  GET /1.0/scope/scope
  Get the possible scopes for hubiC API
  """
 @spec scope() :: ExOvh.Client.raw_query_t
 def scope(), do: {:get, "/1.0/scope/scope", :nil}



end