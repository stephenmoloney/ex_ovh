defmodule ExOvh.Client do
  @moduledoc ~s"""
  A behaviour for setting up an OVH client.

  ## Example setting up the `ExOvh` Client

  Defining a client:

      defmodule ExOvh do
        @moduledoc :false
        use ExOvh.Client, otp_app: :ex_ovh, client: __MODULE__
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
        # default hackney options to each request (optional)
        hackney: [
           connect_timeout: 20000,
           recv_timeout: 100000
        ]

  ## Example using the `ExOvh` client

      %HTTPipe.Request{ method: :get, url: "/me", params: %{}} |> ExOvh.request!()
      %HTTPipe.Request{ method: :get, url: "/cloud/project", params: %{}} |> ExOvh.request!()

  ## Example (2): Setting up an additional `MyApp.MyClient` client.

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
           consumer_key: System.get_env("MY_APP_MY_CLIENT_CONSUMER_KEY")
        ],
        # default hackney options to each request (optional)
        hackney: [
           connect_timeout: 20000,
           recv_timeout: 100000
        ]

  ## Example using the `MyApp.MyClient` client

      %HTTPipe.Request{ method: :get, url: "/me", params: %{}} |> MyApp.MyClient.request!()
      %ExOvh.Query{ method: :get, url: "/cloud/project", params: %{}} |> MyApp.MyClient.request!()
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do

      @moduledoc ~s"""
      A default client for sending requests to the [OVH API](https://api.ovh.com/console/).

      `ExOvh` is the default client. Additional clients such as `MyApp.MyClient.Ovh` can be created - see `PAGES`.
      """
      alias ExOvh.{Defaults, ResponseError}
      @behaviour ExOvh.Client

      # public callback functions

      @doc "Starts the client supervision tree"
      def start_link(sup_opts \\ []) do
        client = unquote(opts) |> Keyword.fetch!(:client)
        otp_app = unquote(opts) |> Keyword.fetch!(:otp_app)
        ExOvh.Supervisor.start_link(client, [otp_app: otp_app])
      end

      @doc "Gets all the application configuration settings"
      @spec config() :: Keyword.t
      def config() do
        client = unquote(opts) |> Keyword.fetch!(:client)
        unless agent_exists?(client), do: __MODULE__.start_link([])
        ExOvh.Config.config(client)
      end

      @doc "Gets all the `:ovh` configuration settings"
      @spec ovh_config() :: Keyword.t
      def ovh_config(), do: config() |> Keyword.fetch!(:ovh)

      @doc "Gets all the default `:hackney` options to be sent with each request"
      @spec hackney_opts() :: Keyword.t
      def hackney_opts(), do: config() |> Keyword.fetch!(:hackney)

      @doc "Sends a request to the ovh api using [httpipe](https://hex.pm/packages/httpipe)."
      @spec request(HTTPipe.Conn.t) :: {:ok, HTTPipe.Conn.t} | {:error, HTTPipe.Conn.t}
      def request(conn) do
        client = unquote(opts) |> Keyword.fetch!(:client)
        ExOvh.Request.request(conn, client)
      end

      @doc "Sends a request to the ovh api using [httpipe](https://hex.pm/packages/httpipe)."
      @spec request!(HTTPipe.Conn.t) :: HTTPipe.Conn.t | no_return
      def request!(conn) do
        case request(conn) do
          {:ok, conn} -> conn
          {:error, conn} -> raise(ResponseError, conn: conn)
        end
      end

      defp agent_name(client) do
        Module.concat(ExOvh.Config, client)
      end

      defp agent_exists?(client) do
        agent_name(client) in Process.registered()
      end

    end
  end

  @callback start_link(sup_opts :: list) :: {:ok, pid} | {:error, atom}
  @callback config() :: Keyword.t
  @callback ovh_config() :: Keyword.t
  @callback hackney_opts() :: Keyword.t
  @callback request(conn :: HTTPipe.Conn.t) :: {:ok, HTTPipe.Conn.t} | {:error, HTTPipe.Conn.t}
  @callback request!(conn :: HTTPipe.Conn.t) :: HTTPipe.Conn.t | no_return

end