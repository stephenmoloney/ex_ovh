defmodule ExOvh.Ovh.Supervisor do
  @moduledoc ~s"""
  Supervisor for the Ovh Configuration
  """
  use Supervisor
  alias ExOvh.Ovh.Cache

  #####################
  #  Public
  #####################

  @doc ~s"""
  Starts the OVH supervisor.
  """
  def start_link(client, config, opts) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: supervisor_name(client)])
  end


  #####################
  #  Callbacks
  #####################

  def init({client, config, opts}) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    workers = [
               {Cache, {Cache, :start_link, [{client, config, opts}]}, :permanent, 10_000, :worker, [Cache]}
              ]
    supervise(workers, strategy: :one_for_one, max_restarts: 20)
  end

  defp supervisor_name(client), do: String.to_atom(Atom.to_string(client) <> Atom.to_string(__MODULE__))


end
