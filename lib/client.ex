defmodule ExOvh.Client do
  @moduledoc :false

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
    opts |> Og.log_return(__ENV__, :debug)

      # client definitions
#
#      defmodule Ovh do
#        otp_app = Keyword.fetch!(opts, :otp_app)
#        use Openstex.Client, otp_app: otp_app, client: __MODULE__
#        def cache(), do: ExOvh.Auth.Ovh.Cache
#      end


#      defmodule Swift.Webstorage do
#        defstruct []
#        otp_app = Keyword.fetch!(opts, :otp_app)
#        use Openstex.Client, otp_app: otp_app, client: __MODULE__
#        def cache(), do: ExOvh.Auth.Openstack.Swift.Cache
#        # use Openstex.Swift.V1.Helpers, client: client, config_id: :webstorage
#      end

#
#      defmodule Swift.Cloudstorage do
#        defstruct []
#        otp_app = Keyword.fetch!(opts, :otp_app)
#        use Openstex.Client, otp_app: otp_app, client: __MODULE__
#        def cache(), do: ExOvh.Auth.Openstack.Swift.Cache
#        # use Openstex.Swift.V1.Helpers, client: client, config_id: :cloudstorage
#      end


#      swift_mods =
#      if (otp_app != :ex_ovh)  do
#        Application.get_env(otp_app, __MODULE__)
#      else
#        Application.get_all_env(otp_app)
#      end
#      |> Keyword.fetch!(:swift)
#      |> Keyword.keys()

        # ** THIS IS READY TO GO ONCE SOLVE PROBLEM INSIDE IT **
#      for mod <- swift_mods do
#        defmodule Module.concat(Helpers.Swift, Utils.module_name(mod)) do
#          mod |> Og.log_return(:debug)
#          Utils.module_name(mod) |> Og.log_return(:debug)
#          Module.concat(Helpers.Swift, Utils.module_name(mod)) |> Og.log_return(:debug)
#          use Openstex.Swift.V1.Helpers, client: client, cache: mod
#        end
#      end


#      defmodule Helpers.Keystone do
#        use Openstex.Helpers.V2.Keystone, client: Keyword.fetch!(opts, :client)
#      end


      # public functions


      def config() do
        otp_app = unquote(opts) |> Keyword.fetch!(:otp_app)
        if (otp_app != :ex_ovh)  do
          Application.get_env(otp_app, __MODULE__)
        else
          Application.get_all_env(:ex_ovh)
        end
      end

      def ovh_config() do
        config() |> Keyword.fetch!(:ovh)
      end

      def swift_config() do
        config() |> Keyword.fetch!(:swift)
      end


      def start_link(sup_opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, ovh_config(), sup_opts)
      end


    end
  end


  @callback start_link() :: :ok | {:error, {:already_started, pid}} | {:error, term}
  @callback config() :: :nil | Keyword.t
  @callback ovh_config() :: :nil | map
  @callback swift_config() :: :nil | map

end

#
#def ovh_config() do
#  otp_app = Keyword.get(unquote(opts), :otp_app, :ex_ovh)
#  if (otp_app != :ex_ovh)  do
#    Application.get_env(otp_app, __MODULE__) |> Keyword.fetch!(:ovh)
#  else
#    Application.get_all_env(otp_app) |> Keyword.fetch!(:ovh)
#  end
#end
#
#def swift_config() do
#  otp_app = Keyword.get(unquote(opts), :otp_app, :ex_ovh)
#  if (otp_app != :ex_ovh)  do
#    Application.get_env(otp_app, __MODULE__) |> Keyword.fetch!(:swift)
#  else
#    Application.get_all_env(otp_app) |> Keyword.fetch!(:swift)
#  end
#  config() |> Keyword.fetch!(:swift)
#end