defmodule ExOvh.Supervisor do
  @moduledoc :false
  use Supervisor


  #  Public


  def start_link(client, opts \\ []) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__,  {client, opts})
  end


  #  Callbacks


  def init({client, opts}) do
    Og.context(__ENV__, :debug)
    sup_tree =
    [
    {client, {ExOvh.Config, :start_agent, [client, opts]}, :permanent, 10_000, :worker, [ExOvh.Config]}
    ]
    supervise(sup_tree, strategy: :one_for_one, max_restarts: 30)
  end


end
