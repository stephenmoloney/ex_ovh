defmodule ExOvh do
  use ExOvh.Client, otp_app: :ex_ovh


  # <<TODO>> Remove application later so that ExOvh is started
  # <<TODO>> within a supervision tree on demand
  use Application

  def start(_type, _args) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    __MODULE__.start_link()
  end


end
