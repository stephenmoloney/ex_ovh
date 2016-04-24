defmodule ExOvh.Client do
  @moduledoc ~S"""
  """
  alias ExOvh.Defaults


  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @otp_app Keyword.get(opts, :otp_app, :ex_ovh)

      use Openstex.Client, client: __MODULE__, swift_cache: __MODULE__.Auth.Openstack.Swift.Cache

      # Incorporation of the Swift Oject Storage Helpers modules.
      defmodule Helpers.Swift do
        %Macro.Env{context_modules: [_, client_module]} = __ENV__
         use Openstex.Helpers.V1.Swift, client: client_module
       end

      # Incorporation of the Custom Ovh Helpers modules.
      defmodule Helpers.Ovh do
       %Macro.Env{context_modules: [_, _, client_module]} = __ENV__
        use ExOvh.Ovh.V1.Webstorage.Helpers, client: client_module
      end


      if (@otp_app != :ex_ovh)  do
        def config(), do: Application.get_env(@otp_app, __MODULE__)
        |> Keyword.fetch!(:ovh)
      else
        def config(), do: Application.get_all_env(@otp_app)
        |> Keyword.fetch!(:ovh)
      end


      def start_link(opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, config(), opts)
      end


    end
  end


  @doc ~s"""
  Starts the ovh supervisors.
  """
  @callback start_link() :: :ok | {:error, {:already_started, pid}} | {:error, term}


  @doc ~s"""
  Gets the ovh config from the application environment.
  """
  @callback config() :: :nil | map


end
