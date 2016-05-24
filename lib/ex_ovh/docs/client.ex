defmodule ExOvh.Client.Docs do
  @moduledoc :false

  @doc :false
  def moduledoc() do
    ~s"""
    A behaviour for setting up an OVH client.

    ## Example (1): Setting up the `ExOvh` Client

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
            endpoint: "ovh-eu",
            api_version: "1.0"
          ],
           httpoison: [ # optional
             connect_timeout: 20000,
             receive_timeout: 100000
          ]

    ## Example using the `ExOvh` client

        %ExOvh.Query{ method: :get, uri: "/me", params: :nil} |> ExOvh.request!()
        %ExOvh.Query{ method: :get, uri: "/cloud/project", params: :nil} |> ExOvh.request!()

    ## Example (2): Setting up an additional MyApp.MyClient.Ovh` client.

    Defining the `MyApp.MyClient`

        defmodule MyApp.MyClient do
          @moduledoc :false
          use ExOvh.Client, otp_app: :my_app
        end

    Configuring the `MyApp.MyClient`

        config :my_app, MyApp.MyClient,
          ovh: [
             application_key: System.get_env("MY_APP_MY_CLIENT_APPLICATION_KEY"),
             application_secret: System.get_env("MY_APP_MY_CLIENT_APPLICATION_SECRET"),
             consumer_key: System.get_env("MY_APP_MY_CLIENT_CONSUMER_KEY"),
             endpoint: "ovh-eu",
             api_version: "1.0"
          ],
          httpoison: [ # optional
             connect_timeout: 20000,
             receive_timeout: 100000
          ]

    ## Example using the `MyApp.MyClient` client

        %ExOvh.Query{ method: :get, uri: "/me", params: :nil} |> MyApp.MyClient.request!()
        %ExOvh.Query{ method: :get, uri: "/cloud/project", params: :nil} |> MyApp.MyClient.request!()
    """
  end


  @doc :false
  def ovh_client_docs() do
    ~s"""
    A default client for sending requests to the [OVH API](https://api.ovh.com/console/).

    `ExOvh` is the default client. Additional clients such as `MyApp.MyClient.Ovh` can be created - see docs.
    """
  end

end