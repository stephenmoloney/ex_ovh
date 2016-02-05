defmodule ExOvh.Supervisor do
  @moduledoc ~s"""
  Supervisor for the Ovh Configuration
  """
  use Supervisor
  alias ExOvh.Ovh.Cache
  alias ExOvh.Ovh.Defaults, as: OvhDefaults
  alias ExOvh.Hubic.Defaults, as: HubicDefaults
  alias ExOvh.Ovh.Supervisor, as: OvhSupervisor
  alias ExOvh.Hubic.Supervisor, as: HubicSupervisor
  require Logger


  #####################
  #  Public
  #####################

  @doc ~s"""
  Starts the OVH and Hubic supervisors.
  """
  def start_link(client, config, opts) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: client])
  end

  #####################
  #  Callbacks
  #####################

  def init({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    sup_tree =
    case ovh_config(config, client) do
      {:error, :config_not_found} ->
        Logger.warn(IO. inspect("No ovh config found. OVH supervisor will not be started for client #{client}"))
        []
      valid_config ->
        [{OvhSupervisor,
         {OvhSupervisor, :start_link, [client, valid_config, opts]}, :permanent, 10_000, :supervisor, [OvhSupervisor]}]
    end
    sup_tree =
    case hubic_config(config, client) do
      {:error, :config_not_found} ->
        LoggingUtils.log_return("No hubic config found. Hubic supervisor will not be started for client #{client}", :warn)
        sup_tree
      valid_config -> sup_tree ++
        [{HubicSupervisor,
         {HubicSupervisor, :start_link, [client, valid_config, opts]}, :permanent, 10_000, :supervisor, [HubicSupervisor]}]
    end
    if sup_tree === [] do
        raise "No configuration found for hubic or ovh."
    end
    supervise(sup_tree, strategy: :one_for_one, max_restarts: 20)
  end



  @doc """
  Returns ovh configuration settings or an error
  if the ovh config is not found
  ## <<TODO>> Add some additional config validation (
  to test absence of essential information)
  """
  @spec ovh_config(config :: map, client :: atom) :: map | {:error, atom}
  def ovh_config(config, client) do
    case config[:ovh] do
      :nil -> {:error, :config_not_found}
      _ -> Map.merge(OvhDefaults.ovh(), client.config()[:ovh])
    end
  end


  @doc """
  Returns hubic configuration settings
  """
  @spec hubic_config(config :: map, client :: atom) :: map | :nil
  def hubic_config(config, client) do
    case config[:hubic] do
      :nil -> {:error, :config_not_found}
      _ -> Map.merge(HubicDefaults.hubic(), client.config()[:hubic])
    end
  end

end
