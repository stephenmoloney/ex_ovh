defimpl Openstex.Request, for: ExOvh.Ovh.Query do
  @moduledoc :false

  alias Openstex.{Auth, Response}
  alias ExOvh.Ovh.Query


  # Public


  @spec request(Query.t, Keyword.t, atom) :: {:ok, Response.t} | {:error, Response.t}
  def request(query, opts, client) do
    Og.context(__ENV__, :debug)

    q = Auth.prepare_request(query, opts, client) |> Map.from_struct()

    options = set_opts(q.options, opts)
    case HTTPoison.request(q.method, q.uri, q.body, q.headers, options) do
      {:ok, resp} ->
        body = parse_body(resp)
        resp = %Response{ body: body, headers: resp.headers |> Enum.into(%{}), status_code: resp.status_code }
        if resp.status_code >= 100 and resp.status_code < 300 do
          {:ok, resp}
        else
          {:error, resp}
        end
      {:error, resp} ->
        {:error, %HTTPoison.Error{reason: resp.reason}}
    end

  end


  # private


  def parse_body(resp) do
    try do
       resp.body |> Poison.decode!()
    rescue
      _ ->
        resp.body
    end
  end


  defp set_opts(query_opts, opts), do: Keyword.merge(query_opts, opts)


end


