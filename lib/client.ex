defmodule ExOvh.Client do
  alias LoggingUtils
  alias ExOvh.Defaults

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @otp_app opts[:otp_app] || :ex_ovh


      if(@otp_app !== :ex_ovh)  do
        def config(), do: Application.get_env(@otp_app, __MODULE__) |> Enum.into(%{})
      else
        def config(), do: Application.get_all_env(@otp_app) |> Enum.into(%{})
      end


      def start_link(opts \\ []) do
        LoggingUtils.log_mod_func_line(__ENV__, :debug)
        ExOvh.Supervisor.start_link(__MODULE__, config(), opts)
      end


      def ovh_request(method, uri, params, signed \\ :true) do
        LoggingUtils.log_mod_func_line(__ENV__, :debug)
        ExOvh.Ovh.Request.request(__MODULE__, method, uri, params, signed)
      end


      def ovh_prep_request(method, uri, params, signed \\ :true) do
        LoggingUtils.log_mod_func_line(__ENV__, :debug)
        ExOvh.Ovh.Auth.prep_request(__MODULE__, method, uri, params, signed)
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
  @callback ovh_request(method :: atom, uri :: string, params :: map, signed :: boolean) :: map


  @doc ~s"""
  Prepares all elements necessary prior to making a request to the ovh api.
  Returns a tuple `{method, uri, options}`
  """
  @callback ovh_prep_request(method :: atom, uri :: String.t, params :: map, signed :: boolean) :: tuple


end
