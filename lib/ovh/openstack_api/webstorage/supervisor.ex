defmodule ExOvh.Ovh.OpenstackApi.Webstorage.Supervisor do
  @moduledoc :false
  use Supervisor
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Cache

  #####################
  #  Public
  #####################

  @doc ~S"""
  Starts the OVH Openstack dynamic supervisor.
  """
  def start_link({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: __MODULE__])
  end


  #####################
  #  Callbacks
  #####################

  def init({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    tree = [
            {Cache, {Cache, :start_link, [{client, config, opts}]}, :transient, 10_000, :worker, []}
           ]
    supervise(tree, strategy: :simple_one_for_one)
  end


end
