defmodule ExOvh.Transformation.Body do
  @moduledoc :false
  alias ExOvh.HttpQuery


  # Public

  @spec apply(HttpQuery.t, binary) :: HttpQuery.t
  def apply(%HttpQuery{completed_transformations: trans} = query, body) when is_binary(body) do
    Map.put(query, :body, body)
    |> Map.put(:completed_transformations, trans ++ [:body])
  end


end
