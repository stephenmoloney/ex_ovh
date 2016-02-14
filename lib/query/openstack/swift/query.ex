defmodule ExOvh.Query.Openstack.Swift do
  @moduledoc ~S"""
  Helper functions for to building queries for the openstack compatible swift apis.

  The raw query can be passed into a client request.

    ## Example

      import ExOvh.Query.Openstack.Swift, only: [scope: 0]
      account = ExOvh.Hubic.OpenstackApi.Cache.get_account()
      client = ExOvh
      scope = ExOvh.hubic_request(account_info(client), %{ openstack: : true })
  """
  alias ExOvh.Hubic.OpenstackApi.Cache, as: HubicOpenstackCache


  #############################
  # CONTAINER RELATED REQUESTS
  #############################


  @doc ~S"""
  GET /v1/​{account}​, Get account details and containers for given account

  ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      account = OpenCache.get_account(client)
      ExOvh.hubic_request(account_info(account), %{ openstack: :true })
      ```
  """
  @spec account_info(account :: String.t) :: [map]
  def account_info(account), do: {:get, account, %{ "format" => "json" }}


  @doc ~S"""
  PUT /v1/​{account}/{container}​, Create a new container

  ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      account = OpenCache.get_account(client)
      ExOvh.hubic_request(create_container(account, "new_container"), %{ openstack: :true })
      ```
  """
  @spec create_container(account :: String.t, container :: String.t)
                         :: ExOvh.Client.raw_query_t
  def create_container(account, container), do: {:put, account <> "/" <> container, %{ "format" => "json" }}


  @doc ~S"""
  DELETE /v1/​{account}/{container}​, Delete a container

  ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      account = OpenCache.get_account(client)
      ExOvh.hubic_request(delete_container(account, "new_container"), %{ openstack: :true })
      ```
  """
  @spec delete_container(account :: String.t, container :: String.t)
                         :: ExOvh.Client.raw_query_t
  def delete_container(account, container), do: {:delete, account <> "/" <> container, %{ "format" => "json" }}


  ##########################
  # OBJECT RELATED REQUESTS
  ##########################


  @doc ~S"""
  GET /v1/​{account}​/{container}, List objects in a container

  ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      account = OpenCache.get_account(client)
      ExOvh.hubic_request(get_objects(account, "default"), %{ openstack: :true })
      ```
  """
  @spec get_objects(account :: String.t, container :: String.t)
                    :: ExOvh.Client.raw_query_t
  def get_objects(account, container), do: {:get, account <> "/" <> container, %{ "format" => "json" }}



  @doc ~S"""
  GET /v1/​{account}​/{container}/{object}, Get/Download a specific object (file)

  ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      file = "server_file.txt"
      container = "new_container"
      account = OpenCache.get_account(client)
      ExOvh.hubic_request(get_object(account, container, file), %{ openstack: :true })
      ```
  """
  @spec get_object(account :: String.t, container :: String.t, object :: String.t)
                   :: ExOvh.Client.raw_query_t
  def get_object(account, container, object), do: {:get, account <> "/" <> container <> "/" <> object, :nil}


  @doc """
  PUT /v1/​{account}​/{container}/{object}, Create or replace an object (file)

    ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      account = OpenCache.get_account(client)
      object_name = "client_file.txt"
      client_object = Kernel.to_string(:code.priv_dir(:ex_ovh)) <> "/" <> object_name
      container = "new_container"
      server_object = String.replace(object_name, "client", "server")
      ExOvh.hubic_request(create_object(account, container, client_object, server_object), %{ openstack: :true })
      ```
  """
  @spec create_object(account :: String.t, container :: String.t, client_object :: String.t, server_object :: String.t)
                      :: ExOvh.Client.raw_query_t
  def create_object(account, container, client_object, server_object) do
    case File.read(client_object) do
      {:ok, binary_object} ->
        path = account <> "/" <> container <> "/" <> server_object
        {:put, path, binary_object}
      {:error, posix_error} ->
        LoggingUtils.log_mod_func_line(__ENV__, :error)
        LoggingUtils.log_return(posix_error, :error)
        raise posix_error
    end
  end


  @doc """
  DELETE /v1/​{account}​/{container}/{object}, Delete an Object (Delete a file)

    ### Example usage

      ```elixir
      import ExOvh.Query.Openstack.Swift
      alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
      client = ExOvh
      account = OpenCache.get_account(client)
      container = "new_container"
      server_object = "server_file.txt"
      ExOvh.hubic_request(delete_object(account, container, server_object), %{ openstack: :true })
  """
  @spec delete_object(account :: String.t, container :: String.t, server_object :: String.t)
                      :: ExOvh.Client.raw_query_t
  def delete_object(account, container, server_object) do
    {:delete, account <> "/" <> container <> "/" <> server_object, :nil}
  end



end








