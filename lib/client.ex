defmodule ExOvh.Client do
  @moduledoc ~s"""
  A behaviour for setting up an OVH client.

  ## Example: Setting up the OVH client

  This client is only setup to use the Ovh api. So only the `ExOvh.Ovh` client will be available as the
  configuration settings for anything else are missing.

  Defining a client:

      defmodule ExOvh do
        @moduledoc :false
        use ExOvh.Client, otp_app: :ex_ovh
      end

  Configuring a client:

      config :ex_ovh,
        ovh: [
          application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
          application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
          consumer_key: System.get_env("EX_OVH_CONSUMER_KEY"),
          endpoint: System.get_env("EX_OVH_ENDPOINT"),
          api_version: System.get_env("EX_OVH_API_VERSION") || "1.0"
        ],
        swift: [
                cloudstorage: [
                                tenant_id: System.get_env("EX_OVH_CLOUDSTORAGE_TENANT_ID"), # mandatory, corresponds to a project id
                                user_id: System.get_env("EX_OVH_CLOUDSTORAGE_USER_ID"), # optional, if absent a user will be created using the ovh api.
                                keystone_endpoint: "https://auth.cloud.ovh.net/v2.0", # default endpoint for keystone (identity) auth
                                region: :nil, # defaults to "SBG1" if set to :nil
                                type: :cloudstorage
                              ]
               ]

  ## Example http calls to the OVH api using the `ExOvh.Ovh` client

      # Using the Query functions built from scratch
      %ExOvh.Ovh.Query{ method: :get, uri: "/me", params: :nil} |> ExOvh.Ovh.request!() |> Map.get(:body)
      %ExOvh.Ovh.Query{ method: :get, uri: "/cloud/project", params: :nil} |> ExOvh.Ovh.request!() |> Map.get(:body)

      # Using the Query functions build using a helper function
      ExOvh.Ovh.V1.Webstorage.Query.get_services() |> ExOvh.Ovh.request!()

  ## Example: Setting up the Ovh client and the Swift Cloudstorage client

  This client is only setup to use the Ovh api and the cloudstorage swift api. So the `MyApp.MyClient.Ovh` client and the `MyApp.MyClient.Cloudstorage` client
  will be available as the configuration settings for anything else are missing.


      defmodule MyApp.MyClient do
        @moduledoc :false
        use ExOvh.Client, otp_app: :my_app
      end


      config :my_app, MyApp.MyClient,
        ovh: [
           application_key: System.get_env("MY_APP_MY_CLIENT_APPLICATION_KEY"),
           application_secret: System.get_env("MY_APP_MY_CLIENT_APPLICATION_SECRET"),
           consumer_key: System.get_env("MY_APP_MY_CLIENT_CONSUMER_KEY"),
           endpoint: System.get_env("MY_APP_MY_CLIENT_ENDPOINT"),
           api_version: System.get_env("MY_APP_MY_CLIENT_API_VERSION") || "1.0"
        ],
        swift: [
                cloudstorage: [
                                tenant_id: System.get_env("MY_APP_MY_CLIENT_CLOUDSTORAGE_TENANT_ID"), # mandatory, corresponds to a project id
                                user_id: System.get_env("MY_APP_MY_CLIENT_CLOUDSTORAGE_USER_ID"), # optional, if absent a user will be created using the ovh api.
                                account_temp_url_key: System.get_env("MY_APP_MY_CLIENT_CLOUDSTORAGE_TEMP_URL_KEY"), # defaults to :nil if absent and won't be added if == :nil.
                                keystone_endpoint: "https://auth.cloud.ovh.net/v2.0", # default endpoint for keystone (identity) auth
                                region: :nil, # defaults to "SBG1" if set to :nil
                                type: :cloudstorage
                              ]
               ]

   ## Example http calls to a Swift compatible service using the `MyApp.MyClient` client

      # Using Query functions
      account = MyApp.MyClient.Swift.Cloudstorage.account()
      container = "ex_ovh_private_test_container"
      Openstex.Swift.V1.Query.get_objects_in_folder("", container, account) |> MyApp.MyClient.Swift.Cloudstorage.request!() |> Map.get(:body)
      Openstex.Swift.V1.Query.container_info(container, account) |> MyApp.MyClient.Swift.Cloudstorage.request!()
      Openstex.Swift.V1.Query.account_info(account) |> MyApp.MyClient.Swift.Cloudstorage.request!()

      # Using Helper functions
      MyApp.MyClient.Swift.Cloudstorage.list_objects!(container)
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias ExOvh.Ovh.Defaults

      # public functions


      def config() do
        otp_app = unquote(opts) |> Keyword.fetch!(:otp_app)
        if (otp_app != :ex_ovh)  do
          Application.get_env(otp_app, __MODULE__)
        else
          Application.get_all_env(:ex_ovh)
        end
      end


      def start_link(sup_opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, sup_opts)
      end

      # client definitions

      defmodule Ovh do
        @moduledoc ExOvh.Client.ovh_docs()
        use Openstex.Client, client: __MODULE__
        def cache(), do: ExOvh.Auth.Ovh.Cache
        @doc :false
        def config() do
          List.last(__ENV__.context_modules).config() |> Keyword.fetch!(:ovh)
          |> Keyword.merge(Defaults.ovh(), fn(k, v1, v2) ->
            case {k, v1} do
              {_, :nil} -> v2
              {:endpoint, v1} -> Defaults.endpoints()[v1]
              _ -> v1
            end
          end)
        end
      end

      defmodule Swift.Webstorage do
        @moduledoc ExOvh.Client.swift_docs()
        use Openstex.Client, client: __MODULE__
        use Openstex.Swift.V1.Helpers, client: __MODULE__

        @doc :false
        def cache(), do: ExOvh.Auth.Openstack.Swift.Cache

        @doc :false
        def config(), do: List.last(__ENV__.context_modules).config() |> Keyword.fetch!(:swift) |> Keyword.fetch!(:webstorage)

        @doc "Returns the swift account string."
        @spec account() :: String.t
        def account(), do: __MODULE__.cache().get_swift_account(__MODULE__)

      end

      defmodule Swift.Cloudstorage do
        @moduledoc ExOvh.Client.swift_docs()
        use Openstex.Client, client: __MODULE__
        use Openstex.Swift.V1.Helpers, client: __MODULE__

        @doc :false
        def cache(), do: ExOvh.Auth.Openstack.Swift.Cache

        @doc :false
        def config() do
          List.last(__ENV__.context_modules).config() |> Keyword.fetch!(:swift) |> Keyword.fetch!(:cloudstorage)
          |> Keyword.merge(Defaults.cloudstorage(), fn(_k, v1, v2) -> if v1 == :nil, do: v2, else: v1 end)
        end

        @doc "Returns the swift account string."
        @spec account() :: String.t
        def account(), do: __MODULE__.cache().get_swift_account(__MODULE__)

      end

    end
  end

  @doc :false
  def ovh_docs() do
    ~s"""
    A default client for sending request to the [OVH API](https://api.ovh.com/console/).

    `ExOvh.Ovh` is the default client. `MyApp.MyClient.Ovh` (or similar) can alternatively be the OVH client provided that the client
    has been created by implementing the `ExOvh.Client` behavior.
    """
  end

  @doc :false
  def swift_docs() do
    ~s"""
    A default client for sending request to the [Swift Compatible API](http://developer.openstack.org/api-ref-objectstorage-v1.html).

    Incorporates the behaviours from the `Openstex.Swift.V1.Helpers` module.
    """
  end

end