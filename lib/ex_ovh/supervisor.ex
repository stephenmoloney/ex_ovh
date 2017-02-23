defmodule ExOvh.Supervisor do
  @moduledoc :false
  use Supervisor


  #  Public


  def start_link(client, opts \\ []) do
    Og.log("***logging context***", __ENV__, :debug)
    Supervisor.start_link(__MODULE__,  {client, opts})
  end


  #  Callbacks


  def init({client, opts}) do
    Og.log("***logging context***", __ENV__, :debug)
    sup_tree =
    [
    {client, {ExOvh.Config, :start_agent, [client, opts]}, :permanent, 10_000, :worker, [ExOvh.Config]}
    ]
    supervise(sup_tree, strategy: :one_for_one, max_restarts: 3, max_seconds: 60) # max restarts 3 in one minute
  end


end
