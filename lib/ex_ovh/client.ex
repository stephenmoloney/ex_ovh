defmodule ExOvh.Client do
  @moduledoc Module.concat(__MODULE__, Docs).moduledoc()
  alias ExOvh.{HttpQuery, Query, Response}

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @moduledoc Module.concat(ExOvh.Client, Docs).ovh_client_docs()
      alias ExOvh.{Defaults, HttpQuery, Query, Request, Response, ResponseError}
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

      @doc "Gets all the `:httpoison` configuration settings"
      @spec httpoison_config() :: Keyword.t
      def httpoison_config(), do: config() |> Keyword.fetch!(:httpoison)

      @doc "Prepares a request prior to sending by adding metadata such as authorization headers."
      @spec prepare_request(Query.t, Keyword.t) :: {:ok, Response.t} | {:error, Response.t}
      def prepare_request(query, httpoison_opts \\ []) do
        client = unquote(opts) |> Keyword.fetch!(:client)
        Transformation.prepare_request(query, httpoison_opts, client)
      end

      @doc "Sends a request to the ovh api using [httpoison](https://hex.pm/packages/httpoison)."
      @spec request(Query.t | HttpQuery.t, Keyword.t) :: {:ok, Response.t} | {:error, Response.t}
      def request(query, httpoison_opts \\ []) do
        client = unquote(opts) |> Keyword.fetch!(:client)
        Request.request(query, httpoison_opts, client)
      end

      @doc "Sends a request to the ovh api using [httpoison](https://hex.pm/packages/httpoison)."
      @spec request!(Query.t | HttpQuery.t, Keyword.t) :: Response.t | no_return
      def request!(query, httpoison_opts \\ []) do
        case request(query) do
          {:ok, resp} -> resp
          {:error, resp} -> raise(ResponseError, response: resp, query: query)
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
  @callback httpoison_config() :: Keyword.t
  @callback prepare_request(query :: Query.t, httpoison_opts :: Keyword.t) :: Query.t | no_return
  @callback request(query :: Query.t | HttpQuery.t, httpoison_opts :: Keyword.t) :: {:ok, Response.t} | {:error, Response.t}
  @callback request!(query :: Query.t | HttpQuery.t, httpoison_opts :: Keyword.t) :: {:ok, Response.t} | no_return

end