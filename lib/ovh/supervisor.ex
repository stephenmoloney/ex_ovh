defmodule ExOvh.Ovh.Supervisor do
  @moduledoc :false
  use Supervisor
  alias ExOvh.Ovh.OvhApi.Cache
  alias ExOvh.Ovh.OpenstackApi.Webstorage.Supervisor, as: Webstorage

  #####################
  #  Public
  #####################

  @doc ~S"""
  Starts the OVH supervisor.
  """
  def start_link(client, config, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: supervisor_name(client)])
  end


  #####################
  #  Callbacks
  #####################

  def init({client, config, opts}) do
    Og.context(__ENV__, :debug)
    tree = [
            {Cache, {Cache, :start_link, [{client, config, opts}]}, :permanent, 10_000, :worker, [Cache]},
            {Webstorage, {Webstorage, :start_link, [{client, config, opts}]}, :permanent, 10_000, :supervisor, [Webstorage]}
           ]
    supervise(tree, strategy: :one_for_one, max_restarts: 20)
  end


  #####################
  #  Private
  #####################

  defp supervisor_name(client), do: String.to_atom(Atom.to_string(client) <> Atom.to_string(__MODULE__))


end
