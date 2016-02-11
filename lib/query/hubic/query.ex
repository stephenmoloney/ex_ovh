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

  @doc "GET /scope/scope, Get the possible scopes for hubiC API"
  @spec scope() :: ExOvh.Client.raw_query_t
  def scope(), do: {:get, "/scope/scope", :nil}


  @doc "GET /account, Get the account object properties"
  @spec account() :: ExOvh.Client.raw_query_t
  def account(), do: {:get, "/account", :nil}


  @doc "GET /account/credentials
  Returns openstack credentials for connecting to the file API"
  @spec openstack_credentials() :: ExOvh.Client.raw_query_t
  def openstack_credentials(), do: {:get, "/account/credentials", :nil}


  @doc "GET /account/usage, Returns used space & quota of your account"
  @spec account_usage() :: ExOvh.Client.raw_query_t
  def account_usage(), do: {:get, "/account/usage", :nil}

  ########################################
  # Link related Requests
  ########################################



  @doc """
  GET /account/links, Get all links as a list of links

    ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      {:ok, resp} = ExOvh.hubic_request(get_links())
      links = resp.body
      ```
  """
  @spec get_links() :: ExOvh.Client.raw_query_t
  def get_links(), do: {:get, "/account/links", :nil}


  @doc """
  GET /account/getAllLinks, Get all published objects' public urls with detailed info

    ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      ExOvh.hubic_request(get_published_links_detailed())
      ```
  """
  @spec get_published_links_detailed() :: ExOvh.Client.raw_query_t
  def get_published_links_detailed(), do: {:get, "/account/getAllLinks", :nil}


  @doc ~s"""
  POST /account/links, Create a public link to a file

  Note: links have a max ttl of 30 days on hubic currently.
  ttl can be 1,5,10,15,20,25 or 30
  See hubic ovh [docs](https://hubic.com/en/faq) under 'What is sharing?'.

  ### Example:
      ```elixir
      import ExOvh.Query.Hubic
      container = "new_container"
      object = "server_file.txt"
      ExOvh.hubic_request(publish_object(container, object))
      ```
  """
  @spec publish_object(container :: String.t, object :: String.t)
                             :: ExOvh.Client.raw_query_t
  def publish_object(container, object) do
    params = %{
               "comment": "none",
               "container": container,
               "mode": "ro",
               "ttl": "5",
               "type": "file",
               "uri": URI.encode_www_form("/" <> object),
              }
    {:post, "/account/links", params}
  end




  ########################################
  # HUBIC API FOLDER RELATED REQUESTS
  ########################################


end