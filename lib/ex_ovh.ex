defmodule ExOvh do
  @moduledoc File.read!("#{__DIR__}/../README.md") |> String.replace("# ExOvh", "")
  use ExOvh.Client, otp_app: :ex_ovh
end
