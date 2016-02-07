defmodule ExOvh.Client do
  alias LoggingUtils
  alias ExOvh.Defaults

  # <<TODO>> Reconsider is here the best place to declare the types
  @type method_t :: atom()
  @type path_t :: String.t
  @type params_t :: map() | :nil
  @type options_t :: map() | :nil

  @type raw_query_t :: { method_t, path_t, params_t }
  @type query_t :: { method_t, path_t, options_t }

  @type response_t :: %{ body: map(), headers: map(), status_code: integer() }

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


      def ovh_request({method, uri, params} = query) do
        ExOvh.Ovh.Request.request(__MODULE__, query)
      end


      def ovh_request({method, uri, params} = query) do
        ExOvh.Ovh.Request.request(__MODULE__, query)
      end


      def ovh_prep_request({method, uri, params} = query) do
        ExOvh.Ovh.Auth.prep_request(__MODULE__, query)
      end


    end
  end


  @doc """
  Starts the ovh and the hubic supervisors.
  """
  @callback start_link() :: :ok | {:error, {:already_started, pid}} | {:error, term}


  @doc ~s"""
  Makes a request to the ovh api.
  Returns a map `%{ body: <body>, headers: [<headers>], status_code: <code>}`
  """
  @callback ovh_request(query :: raw_query_t)
                        :: {:ok, response_t} | {:error, response_t}


  @doc ~s"""
  Prepares all elements necessary prior to making a request to the ovh api.
  Returns a tuple `{method, uri, options}`
  """
  @callback ovh_prep_request(query :: raw_query_t)
                             :: query_t


end
