defmodule ExOvh.Auth.Openstack.Supervisor do
  @moduledoc :false

  use Supervisor
  alias ExOvh.Auth.Openstack.Swift.Cache


  #  Public


  def start_link(client \\ []) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, client, [name: __MODULE__])
  end


  #  Callbacks


  def init(client) do
    Og.context(__ENV__, :debug)
    tree = [
            {Cache, {Cache, :start_link, []}, :transient, 10_000, :worker, []}
           ]
    supervise(tree, strategy: :simple_one_for_one)
  end


end