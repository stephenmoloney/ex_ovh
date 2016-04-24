defmodule ExOvh.Auth.Supervisor do
  @moduledoc :false

  use Supervisor
  import ExOvh.Utils, only: [supervisor_name: 1]
  alias ExOvh.Auth.Ovh.Cache, as: OvhCache
  alias ExOvh.Auth.Openstack.Swift.Cache, as: SwiftCache


  #  Public


  @doc ~S"""
  Starts the OVH supervisor.
  """
  def start_link(client, config, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: supervisor_name(client)])
  end


  # Supervisor Callbacks


  def init({client, config, opts}) do
    Og.context(__ENV__, :debug)
    Og.log({client, config, opts}, __ENV__, :debug)

    tree = [
            {OvhCache,
              {OvhCache, :start_link, [{client, config, opts}]}, :transient, 10_000, :worker, [OvhCache]},
#            {SwiftCache,
#              {SwiftCache, :start_link, [{client, config, opts}]}, :permanent, 10_000, :worker, [SwiftCache]}
           ]

    supervise(tree, strategy: :one_for_one)
  end


end
