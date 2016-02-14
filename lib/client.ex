defmodule ExOvh.Client do
  @moduledoc ~S"""
  Defines a client.

  When used, it expects the :otp_app as an option. The :otp_app should be an
  application with the configuration settings for ovh and/or hubic.

  ## Example app using the `ExOvh.Client` behaviour

      defmodule TestOs.ExOvh do
        use ExOvh.Client, otp_app: :test_os
      end

  ## Example configuration

      config :test_os, TestOs.ExOvh,
        ovh:  %{
                application_key: "<app_key>",
                application_secret: "<app_secret>",
                consumer_key: "<con_key>"
        },
        hubic: %{
                client_id: "<client_id>",
                client_secret: "<client_secret>",
                refresh_token: "<refresh_token>",
                redirect_uri: "<redirect_uri>"
                }

  Either ovh or hubic can be set to :nil but not both. Both hubic and ovh being absent
  will result in the supervision tree crashing since there are no application data with
  which to authenticate requests.
  For example, if hubic is set to :nil, then the hubic side of the supervision tree
  will not be started. Then the only functions available will be:

      TestOs.ExOvh.ovh_request/3
      TestOs.ExOvh.ovh_prepare_request/3
  """
  alias ExOvh.Defaults


  @type method_t :: atom()
  @type path_t :: String.t
  @type params_t :: map() | :nil
  @type options_t :: map() | :nil
  @type raw_query_t :: { method_t, path_t, params_t }
  @type query_t :: { method_t, path_t, options_t }
  @type response_t :: %{ body: map() | String.t, headers: map(), status_code: integer() }


  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @otp_app opts[:otp_app] || :ex_ovh


      if(@otp_app !== :ex_ovh)  do
        def config(), do: Application.get_env(@otp_app, __MODULE__) |> Enum.into(%{})
      else
        def config(), do: Application.get_all_env(@otp_app) |> Enum.into(%{})
      end


      def start_link(opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, config(), opts)
      end


      def ovh_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Ovh.Request.request(__MODULE__, query, opts)
      end


      def ovh_prepare_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Ovh.Auth.prepare_request(__MODULE__, query, opts)
      end


      def hubic_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Hubic.Request.request(__MODULE__, query, opts)
      end


      def hubic_prepare_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Hubic.Auth.prepare_request(__MODULE__, query, opts)
      end


    end
  end


  @doc """
  Starts the ovh and the hubic supervisors.
  """
  @callback start_link() :: :ok | {:error, {:already_started, pid}} | {:error, term}


  @doc ~S"""
  Gets the ovh and hubic config from the application environment.

  Returns a map if the config is present in the config.exs file(s)
  or
  Returns :nil if the config is absent.
  """
  @callback config() :: :nil | map



  @doc """
  Prepares all elements necessary for making a request to the ovh api.

  Returns a tuple `{method, uri, options}` which is the `query_t` tuple.
  With the returned query_t, a request can easily be made with
  [HTTPotion](http://hexdocs.pm/httpotion/HTTPotion.html).

  ## Example

  Building a request to the custom ovh api:
      raw_query = {:get, "<account_name>", %{"format" => "json"}}
      query = ExOvh.ovh_prepare_request(raw_query, %{})


  Building a request to the openstack compliant ovh cdn webstorage service:
      raw_query = {:get, "<account_name>", %{"format" => "json"}}
      query = ExOvh.ovh_prepare_request(raw_query, %{ openstack: :true, webstorage: "<ovh_service_name>" })
  """
  @callback ovh_prepare_request(query :: raw_query_t)
                             :: query_t



  @doc ~S"""
  Makes a request to the ovh api.

  Returns a `response_t` map  with the structure:
  `%{ body: <body>, headers: [<headers>], status_code: <code>}`

  ## Example

  Making a request to the custom ovh api:
      raw_query = {:get, "<account_name>", %{"format" => "json"}}
      ExOvh.ovh_request(raw_query, %{})

  Making a request to the openstack compliant ovh cdn webstorage service:
      raw_query = {:get, "<account_name>", %{"format" => "json"}}
      ExOvh.ovh_request(raw_query, %{ openstack: :true, webstorage: "<ovh_service_name>" })
  """
  @callback ovh_request(query :: raw_query_t, opts :: map)
                        :: {:ok, response_t} | {:error, response_t}




  @doc ~S"""
  Makes a request to the hubic api.

  Returns a map `%{ body: <body>, headers: %{<headers>}, status_code: <code>}`

  Making a request to the custom hubic api:
      raw_query = {:get, "/scope/scope", :nil}
      ExOvh.hubic_request(raw_query, %{})

  Making a request to the openstack compliant hubic storage:
      client = ExOvh
      account = ExOvh.Hubic.OpenstackApi.Cache.get_account(client)
      raw_query = {:get, account, %{"format" => "json"}}
      ExOvh.hubic_request(raw_query, %{ openstack: :true })
  """
  @callback hubic_request(query :: raw_query_t, opts :: map)
                         :: {:ok, response_t} | {:error, response_t}


  @doc ~S"""
  Prepares all elements necessary for making a request to the hubic api.

  Returns a tuple `{method, uri, options}`

  Building a request to the custom hubic api:
      raw_query = {:get, "/scope/scope", :nil}
      ExOvh.hubic_prepare_request(raw_query, %{})

  Building a request to the openstack compliant hubic storage
  with the default client `ExOvh`:

      account = ExOvh.Hubic.OpenstackApi.Cache.get_account()
      raw_query = {:get, account, %{"format" => "json"}}
      ExOvh.hubic_prepare_request(raw_query, %{ openstack: :true })


  Building a request to the openstack compliant hubic storage with your own
  client:

      client = MyApp.ExOvh # <-- enter your client here.
      account = ExOvh.Hubic.OpenstackApi.Cache.get_account(client)
      raw_query = {:get, account, %{"format" => "json"}}
      ExOvh.hubic_prepare_request(raw_query, %{ openstack: :true })
  """
  @callback hubic_prepare_request(query :: raw_query_t)
                               :: query_t


end
