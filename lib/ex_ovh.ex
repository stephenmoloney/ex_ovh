defmodule ExOvh do
  @moduledoc :false
  @ex_ovh_config Application.get_all_env(:ex_ovh) |> Keyword.get(:ovh, :nil)

  # Define a standard ExOvh client only if the user has entered a config :ex_ovh, ex_ovh: %{...} into the configuration file.
  unless  @ex_ovh_config in [%{}, :nil] do
    use ExOvh.Client, otp_app: :ex_ovh
  end

end