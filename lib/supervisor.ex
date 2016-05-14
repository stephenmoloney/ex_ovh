defmodule ExOvh.Supervisor do
  @moduledoc :false

  use Supervisor
  alias ExOvh.Ovh.Defaults
  alias ExOvh.Auth.Ovh.Cache, as: OvhCache
  alias ExOvh.Auth.Openstack.Swift.Cache, as: SwiftCache



  #  Public


  def start_link(client, opts) do
    Og.context(__ENV__, :debug)
    Supervisor.start_link(__MODULE__, client, [name: client])
  end


  #  Callbacks


  def init(client) do
    Og.context(__ENV__, :debug)


    webstorage_config = Keyword.get(client.config(), :swift, []) |> Keyword.get(:webstorage, :nil)
    cloudstorage_config = Keyword.get(client.config(), :swift, []) |> Keyword.get(:cloudstorage, :nil)
                          |> Keyword.merge(Defaults.cloudstorage(), fn(_k, v1, v2) -> if v1 == :nil, do: v2, else: v1 end)

    ovh_client = Module.concat(client, Ovh)
    sup_tree = [
                {ovh_client, {OvhCache, :start_link, [ovh_client]}, :permanent, 10_000, :worker, [OvhCache]}
               ]

    sup_tree =
    case webstorage_config do
      :nil ->
        Og.log("No webstorage config found. Skipping initiation of OVH webstorage cdn service", :debug)
        sup_tree
      webstorage_config ->
        webstorage_client = Module.concat(client, Swift.Webstorage)
        sup_tree ++
        [{webstorage_client, {SwiftCache, :start_link, [{ovh_client, webstorage_client}]}, :permanent, 10_000, :worker, [SwiftCache]}]
    end

    sup_tree =
    case cloudstorage_config do
      :nil ->
        Og.log("No cloudstorage config found. Skipping initiation of OVH cloudstorage service", :debug)
        sup_tree
      cloudstorage_config ->
        cloudstorage_client = Module.concat(client, Swift.Cloudstorage)
        sup_tree ++
        [{cloudstorage_client, {SwiftCache, :start_link, [{ovh_client, cloudstorage_client}]}, :permanent, 10_000, :worker, [SwiftCache]}]
    end

    supervise(sup_tree, strategy: :one_for_one, max_restarts: 30)
  end


end
