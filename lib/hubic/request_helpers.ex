defmodule ExOvh.Hubic.RequestHelpers do
  @moduledoc ~S"""
  Helper functions for making requests to the hubic custom api and hubic openstack api.
  """
  import ExOvh.Query.Openstack.Swift
  alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache


  @doc ~S"""
  Gets a list of all openstack swift containers for the hubic app

  Returns `{:ok, [<container_name>, <container_name> ...]`
  or
  Returns `{:error, resp}`

  ## Example

      alias ExOvh.Hubic.RequestHelpers
      client = ExOvh # Enter your client here
      RequestHelpers.containers(client)
  """
  @spec containers(client :: atom)
                   :: {:ok, [String.t]} | {:error, ExOvh.Client.response_t}
  def containers(client) do
    account = OpenCache.get_account(client)
    case ExOvh.hubic_request(account_info(account), %{ openstack: :true }) do
      {:ok, resp} ->
        Og.log_return(resp)
        {:ok, resp.body |> Enum.map(fn(%{"name" => container}) -> container end)}
      {:error, resp} ->
        {:error, resp}
    end
  end


  @doc ~S"""
  Gets a list of all objects by name in an openstack swift container for the hubic app
  Allows to filter the returned list by hash or by name depending on the filter used.

  Returns `{:ok, [<object_name>, <object_name> ...]`
  or
  Returns `{:error, resp}`

  ## Example

      alias ExOvh.Hubic.RequestHelpers
      client = ExOvh
      container = "new_container"
      RequestHelpers.get_objects(client, container, :name)


  ## Example

      alias ExOvh.Hubic.RequestHelpers
      client = ExOvh
      container = "new_container"
      RequestHelpers.get_objects(client, container, :hash)
  """
  @spec get_objects(client :: atom, container :: String.t, filter :: atom)
                   :: {:ok, [String.t]} | {:error, ExOvh.Client.response_t}
  def get_objects(client, container, filter)

  def get_objects(client, container, :name) do
    account = OpenCache.get_account(client)
    case ExOvh.hubic_request(get_objects(account, container), %{ openstack: :true }) do
      {:ok, resp} ->
        Og.log_return(resp)
        {:ok, resp.body |> Enum.map(fn(%{"name" => object_name}) -> object_name end)}
      {:error, resp} ->
        {:error, resp}
    end
  end

  def get_objects(client, container, :hash) do
    account = OpenCache.get_account(client)
    case ExOvh.hubic_request(get_objects(account, container), %{ openstack: :true }) do
      {:ok, resp} ->
        Og.log_return(resp)
        {:ok, resp.body |> Enum.map(fn(%{"hash" => object_hash}) -> object_hash end)}
      {:error, resp} ->
        {:error, resp}
    end
  end


end