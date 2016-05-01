defmodule ExOvh.Client do
  @moduledoc :false

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

      # IS THIS SUPERVISOR NEEDED --> START 2 SEPARATE SUPERVISORS ??
      def start_link(sup_opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, sup_opts)
      end

      # client definitions

      defmodule Ovh do
        use Openstex.Client, client: __MODULE__
        def cache(), do: ExOvh.Auth.Ovh.Cache
        def config(), do: List.last(__ENV__.context_modules).config() |> Keyword.fetch!(:ovh) |> Keyword.merge(Defaults.ovh())
      end

      defmodule Swift.Webstorage do
        defstruct []
        use Openstex.Client, client: __MODULE__
        def cache(), do: ExOvh.Auth.Openstack.Swift.Cache
        def config(), do: List.last(__ENV__.context_modules).config() |> Keyword.fetch!(:swift) |> Keyword.fetch!(:webstorage)
        # use Openstex.Swift.V1.Helpers, client: __MODULE__
      end

      defmodule Swift.Cloudstorage do
        defstruct []
        use Openstex.Client, client: __MODULE__
        def cache(), do: ExOvh.Auth.Openstack.Swift.Cache
        def config(), do: List.last(__ENV__.context_modules).config() |> Keyword.fetch!(:swift) |> Keyword.fetch!(:cloudstorage)
        # use Openstex.Swift.V1.Helpers, client: __MODULE__
      end

#      defmodule Helpers.Keystone do
#        use Openstex.Helpers.V2.Keystone, client: Keyword.fetch!(opts, :client)
#      end


    end
  end

end