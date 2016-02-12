defmodule ExOvh.Query.Hubic do
  @moduledoc ~s"""
    Helps to build queries for the hubic api.

    The raw query can be passed into a client request.

    ## Example

      ```elixir
      import ExOvh.Query.Hubic, only: [scope: 0]
      scope = ExOvh.hubic_request(scope())
      ```
  """


  #########################
  # General Hubic Requests
  #########################

  @doc ~s"""
  GET /scope/scope, Get the possible scopes for hubiC API

    ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(scope())
  """
  @spec scope() :: ExOvh.Client.raw_query_t
  def scope(), do: {:get, "/scope/scope", :nil}


  @doc ~s"""
  GET /account, Get the account object properties

    ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(account())
  """
  @spec account() :: ExOvh.Client.raw_query_t
  def account(), do: {:get, "/account", :nil}


  @doc ~s"""
  GET /account/credentials, Returns openstack credentials for connecting to the file API

      ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(openstack_credentials())
  """
  @spec openstack_credentials() :: ExOvh.Client.raw_query_t
  def openstack_credentials(), do: {:get, "/account/credentials", :nil}


  @doc ~s"""
  GET /account/usage, Returns used space & quota of your account

      ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(account_usage())
  """
  @spec account_usage() :: ExOvh.Client.raw_query_t
  def account_usage(), do: {:get, "/account/usage", :nil}



  ########################
  # Link related Requests
  ########################



  @doc """
  GET /account/links, Get all links as a list of links (showing the object internal uri - not the indirectUri)

    ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(get_links())
      ```
  """
  @spec get_links() :: ExOvh.Client.raw_query_t
  def get_links(), do: {:get, "/account/links", :nil}


  @doc """
  GET /account/getAllLinks, Get all published objects' public urls with detailed info

    ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(get_links_detailed())
      ```
  """
  @spec get_links_detailed() :: ExOvh.Client.raw_query_t
  def get_links_detailed(), do: {:get, "/account/getAllLinks", :nil}


  @doc """
  GET /account/links/{uri}, Get detailed information for an object at a given uri


  ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      container = "new_container"
      folder = "/"
      object = "server_file.txt"
      uri = folder <> object
      ExOvh.hubic_request(get_link(uri))
  """
  @spec get_link(uri :: String.t) :: ExOvh.Client.raw_query_t
  def get_link(uri), do: {:get, "/account/links/", uri}


  @doc ~s"""
  POST /account/links, Create a public url to a file

  Note: links have a max ttl of 30 days on hubic currently.
  ttl can be 1,5,10,15,20,25 or 30
  See hubic ovh [docs](https://hubic.com/en/faq) under 'What is sharing?'.

  ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      container = "new_container"
      object = "server_file.txt"
      {:ok, resp} = ExOvh.hubic_request(publish_object(container, object))
      %{ "indirectUrl" => link_indirect_uri, "expirationDate" => exp,
         "creationDate" => created_on, "uri" => uri } = resp.body
      object_attrs = %{
                      link: link_indirect_uri,
                      expiry: exp,
                      created: created_on,
                      object: object,
                      folder: String.replace(uri, object, ""),
                      object_uri: uri
                     }
      ```
  """
  @spec publish_object(container :: String.t, object :: String.t, opts :: map)
                             :: ExOvh.Client.raw_query_t
  def publish_object(container, object, folder \\ "/", ttl \\ "5", file \\ "file") do
    params = %{
               "comment" => "none",
               "container" => container,
               "mode" => "ro",
               "ttl" => ttl,
               "type" => file,
               "uri" => folder <> object
              }
    {:post, "/account/links", params}
  end



  @doc ~s"""
  DELETE /account/links/{uri}, Deletes a public url to a file


  ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      container = "new_container"
      object = "server_file.txt"
      folder = "/"
      uri = folder <> object
      ExOvh.hubic_request(delete_link(uri))
  """
  @spec delete_link(uri :: String.t) :: ExOvh.Client.raw_query_t
  def delete_link(uri), do: {:delete, "/account/links/", uri}



  ########################################
  # Folder related requests
  ########################################




end