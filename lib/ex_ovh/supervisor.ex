defmodule ExOvh.Supervisor do
  @moduledoc :false
  use Supervisor


  #  Public


  def start_link(client, _opts \\ []) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, client)
  end


  #  Callbacks


  def init(client) do
    Og.context(__ENV__, :debug)
    sup_tree = [{client, {ExOvh.Cache, :start_link, [client]}, :permanent, 10_000, :worker, [ExOvh.Cache]}]
    supervise(sup_tree, strategy: :one_for_one, max_restarts: 30)
  end


end
