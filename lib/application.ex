defmodule ExOvh.Application do
  @moduledoc :false
  use Application

  # Start the ex_ovh client only if a config :ex_ovh, ex_ovh: %{...} configuration file has been set.
  def start(_type, _args) do
    ExOvh.start_link(__MODULE__)
  end

end
