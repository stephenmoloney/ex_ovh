defmodule ExOvh.Application do
  @moduledoc :false
  use Application
  @ex_ovh_config Application.get_all_env(:ex_ovh) |> Keyword.get(:ovh, :nil)

  # Start the ex_ovh client only if a config :ex_ovh, ex_ovh: %{...} configuration file has been set.
  unless @ex_ovh_config in [%{}, :nil] do
    def start(_type, _args) do
      ExOvh.Supervisor.start_link(ExOvh, @ex_ovh_config, :ex_ovh)
    end
  end

end
