defmodule ExOvh.Transformation.HackneyOptions do
  @moduledoc :false
  alias ExOvh.HttpQuery


  # Public

  @spec apply(HttpQuery.t, atom) :: HttpQuery.t
  def apply(%HttpQuery{hackney_options: hackney_options, completed_transformations: trans} = query, client) do
    options = merge_options(client.hackney_opts(), hackney_options)
    Map.put(query, :hackney_options, options)
    |> Map.put(:completed_transformations, trans ++ [:hackney_options])
  end


  # Private

  defp merge_options(opts1, opts2) do
    opts1 = Enum.into(opts1, %{})
    opts2 = Enum.into(opts2, %{})
    opts = Map.merge(opts1, opts2)
    Enum.into(opts, [])
  end

end
