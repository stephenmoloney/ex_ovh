defmodule ExOvh.Hubic.Supervisor do
  @moduledoc :false
  use Supervisor
  alias ExOvh.Hubic.HubicApi.Cache, as: TokenCache
  alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenstackCache

  #####################
  # Public
  #####################

  def start_link(client, config, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, {client, config, opts}, [name: supervisor_name(client)])
  end

  #####################
  # Supervisor Callbacks
  #####################

  def init({client, config, opts}) do
    Og.context(__ENV__, :debug)
    workers = [
                {TokenCache, {TokenCache, :start_link, [{client, config, opts}]}, :permanent, 15000, :worker, [TokenCache]},
                {OpenstackCache, {OpenstackCache, :start_link, [{client, config, opts}]}, :permanent, 20000, :worker, [OpenstackCache]}
              ]
    supervise(workers, strategy: :one_for_one, max_restarts: 20)
  end

  defp supervisor_name(client), do: String.to_atom(Atom.to_string(client) <> Atom.to_string(__MODULE__))

end
