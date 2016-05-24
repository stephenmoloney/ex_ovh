defmodule ExOvh.Client do
  @moduledoc Module.concat(__MODULE__, Docs).moduledoc()

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @moduledoc Module.concat(ExOvh.Client, Docs).ovh_client_docs()
      alias ExOvh.{Defaults, HttpQuery, Query, Request, Response, ResponseError}
      @behaviour ExOvh.Client


      # public functions

      @doc :false
      def start_link(sup_opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, sup_opts)
      end

      @doc "Gets all the application configuration settings"
      @spec config() :: Keyword.t
      def config() do
        otp_app = unquote(opts) |> Keyword.fetch!(:otp_app)
        case otp_app do
          :ex_ovh -> Application.get_all_env(otp_app)
          _ ->  Application.get_env(otp_app, __MODULE__)
        end
      end


      @doc "Gets all the `:ovh` configuration settings"
      @spec ovh_config() :: Keyword.t
      def ovh_config() do
        config()
        |> Keyword.fetch!(:ovh)
        |> Keyword.merge(Defaults.ovh(), fn(k, v1, v2) ->
          case {k, v1} do
            {_, :nil} -> v2
            {:endpoint, v1} -> Defaults.endpoints()[v1]
            _ -> v1
          end
        end)
      end


      @doc "Gets all the `:httpoison` configuration settings"
      @spec httpoison_config() :: Keyword.t
      def httpoison_config() do
        default_opts = [connect_timeout: 30000, receive_timeout: (60000 * 30)]
        httpoison = Keyword.get(config(), :httpoison, default_opts)
        config()
        |> Keyword.put(:timeout, httpoison[:connect_timeout])
        |> Keyword.put(:recv_timeout, httpoison[:receive_timeout])
        |> Keyword.delete(:connect_timeout)
        |> Keyword.delete(:receive_timeout)
      end


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

      defoverridable [
                start_link: 0,
                ovh_config: 0,
                httpoison_config: 0,
                request: 2,
                request!: 2,
                prepare_request: 2
               ]

    end
  end


  @callback start_link() :: {:ok, pid} | {:error, atom}
  @callback ovh_config() :: Keyword.t
  @callback httpoison_config() :: Keyword.t
  @callback prepare_request(query :: map, httpoison_opts :: Keyword.t) :: Query.t | no_return
  @callback request(query :: map, httpoison_opts :: Keyword.t) :: {:ok, Response.t} | {:error, Response.t}
  @callback request!(query :: map, httpoison_opts :: Keyword.t) :: {:ok, Response.t} | no_return


end