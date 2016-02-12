defmodule ExOvh.Ovh.OpenstackApi.Webstorage.Supervisor do
  @moduledoc ~s"""
  Supervisor for the Ovh Openstack Configurations.

  Rather than adding every single instance of an openstack account to the `secret.prod.exs` file, it is
  probably better to start the openstack workers on demand.

  The openstack workers cache the openstack token and maintain it.
  """
  use Supervisor
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Cache

  #####################
  #  Public
  #####################

  @doc ~s"""
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
