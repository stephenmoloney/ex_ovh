defmodule ExOvh do
  use ExOvh.Client, otp_app: :ex_ovh, client: __MODULE__
end