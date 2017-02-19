defmodule ExOvh.Request do
  @moduledoc :false
  alias ExOvh.{Transformation, HttpQuery, Response}


  # Public
  @spec request(HttpQuery.t, atom) :: {:ok, Response.t} | {:error, Response.t}
  def request(%HttpQuery{} = query, client) do
    Og.context(__ENV__, :debug)

    q = apply_transformations(query, client)

    case :hackney.request(q.method, q.uri, q.headers, q.body, q.hackney_options) do
      {:ok, resp} ->
        Og.log_return(resp, __ENV__, :debug)
        
        body = parse_body(resp)
        resp = %Response{ body: body, headers: resp.headers |> Enum.into(%{}), status_code: resp.status_code }
        if resp.status_code >= 100 and resp.status_code < 400 do
          {:ok, resp}
        else
          {:error, resp}
        end
      {:error, resp} -> {:error, resp}
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


  defp apply_transformations(%HttpQuery{} = query, client) do
    query =
    unless (:auth in query.completed_transformations) do
      Transformation.Auth.apply(query, client)
    else
      query
    end
    query =
    unless (:uri in query.completed_transformations) do
     Transformation.Uri.apply(query, client)
    else
      query
    end
    query =
    unless (:body in query.completed_transformations) do
      Transformation.Body.apply(client, "")
    else
      query
    end
    unless (:hackney_options in query.completed_transformations) do
      Transformation.HackneyOptions.apply(query, client)
    else
      query
    end
  end

end
