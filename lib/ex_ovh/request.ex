defmodule ExOvh.Request do
  @moduledoc :false
  alias ExOvh.{Transformation, Query, Response}


  # Public


  @spec request(Query.t, Keyword.t, atom) :: {:ok, Response.t} | {:error, Response.t}
  def request(%Query{} = query, httpoison_opts, client) do
    Og.context(__ENV__, :debug)
    q = Transformation.prepare_request(query, httpoison_opts, client) |> Map.from_struct()
    options = Keyword.merge(q.options, httpoison_opts)
    case HTTPoison.request(q.method, q.uri, q.body, q.headers, options) do
      {:ok, resp} ->
        body = parse_body(resp)
        resp = %Response{ body: body, headers: resp.headers |> Enum.into(%{}), status_code: resp.status_code }
        if resp.status_code >= 100 and resp.status_code < 400 do
          {:ok, resp}
        else
          {:error, resp}
        end
      {:error, resp} ->
        {:error, %HTTPoison.Error{reason: resp.reason}}
    end

  end


  # private


  defp parse_body(resp) do
    try do
       resp.body |> Poison.decode!()
    rescue
      _ ->
        resp.body
    end
  end


end


