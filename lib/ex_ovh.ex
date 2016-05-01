defmodule ExOvh do
  @moduledoc :false

  use ExOvh.Client, otp_app: :ex_ovh

end

# The following way multiple clients to be configured and created.
#defmodule MyApp.ExOvhClient1 do
#  @moduledoc :false
#  use ExOvh.Client, otp_app: :my_app
#end

