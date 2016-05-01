defmodule ExOvh.Supervisor do
  @moduledoc :false

  use Supervisor
  alias ExOvh.Defaults
  alias ExOvh.Auth.Supervisor, as: AuthSupervisor


  #  Public


  def start_link(client, ovh_config, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, ovh_config, opts}, [name: client])
  end


  #  Callbacks


  def init({client, ovh_config, opts}) do
    Og.context(__ENV__, :debug)
    sup_tree =
    case ovh_config(ovh_config, client) do
      {:error, :config_not_found} ->
        Og.log("No ovh config found. Ovh supervisor will not be started for client #{client}", :error)
        []
      valid_ovh_config ->
        [{AuthSupervisor,
         {AuthSupervisor, :start_link, [client, valid_ovh_config, opts]}, :permanent, 10_000, :supervisor, [AuthSupervisor]}]
    end
    if sup_tree === [] do
        raise "No configuration found for ovh."
    end
    supervise(sup_tree, strategy: :one_for_one, max_restarts: 20)
  end


  @doc "Gets the ovh config settings."
  @spec ovh_config(map, atom) :: map | {:error, :config_not_found}
  def ovh_config(ovh_config, client) do
    case ovh_config do
      :nil -> {:error, :config_not_found}
      _ -> Map.merge(Defaults.ovh(), client.ovh_config())
    end
  end


end
