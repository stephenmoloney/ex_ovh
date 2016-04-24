defmodule ExOvh.Supervisor do
  @moduledoc :false

  use Supervisor
  alias ExOvh.Defaults
  alias ExOvh.Auth.Supervisor, as: AuthSupervisor


  #  Public


  def start_link(client, config, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: client])
  end


  #  Callbacks


  def init({client, config, opts}) do
    Og.context(__ENV__, :debug)
    sup_tree =
    case ovh_config(config, client) do
      {:error, :config_not_found} ->
        Og.log("No ovh config found. Ovh supervisor will not be started for client #{client}", :error)
        []
      valid_config ->
        [{AuthSupervisor,
         {AuthSupervisor, :start_link, [client, valid_config, opts]}, :permanent, 10_000, :supervisor, [AuthSupervisor]}]
    end
    if sup_tree === [] do
        raise "No configuration found for ovh."
    end
    supervise(sup_tree, strategy: :one_for_one, max_restarts: 20)
  end


  @doc """
  Gets the ovh config settings.
  """
  @spec ovh_config(config :: map, client :: atom) :: map | {:error, atom}
  def ovh_config(config, client) do
    case config do
      :nil -> {:error, :config_not_found}
      _ -> Map.merge(Defaults.ovh(), client.config())
    end
  end


end
