defmodule ExOvh.Auth.Supervisor do
  @moduledoc :false

  use Supervisor
  import ExOvh.Utils, only: [supervisor_name: 1]
  alias ExOvh.Auth.Ovh.Cache, as: OvhCache
  alias ExOvh.Auth.Openstack.Supervisor, as: OpenstackSupervisor


  #  Public


  def start_link(client, ovh_config, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, ovh_config, opts}, [name: supervisor_name(client)])
  end


  # Supervisor Callbacks


  def init({client, ovh_config, opts}) do
    Og.context(__ENV__, :debug)

    tree = [
            {OvhCache,
              {OvhCache, :start_link, [{client, ovh_config, opts}]}, :permanent, 10_000, :worker, [OvhCache]},
            {OpenstackSupervisor,
              {OpenstackSupervisor, :start_link, []}, :permanent, 10_000, :supervisor, [OpenstackSupervisor]}
           ]
    supervise(tree, strategy: :one_for_one)
  end


end
