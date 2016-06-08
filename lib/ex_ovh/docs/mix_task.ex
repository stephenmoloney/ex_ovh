defmodule Mix.Tasks.Ovh.Docs do
  @moduledoc :false

  @doc :false
  def moduledoc() do
    ~s"""
    A mix task that generates the ex_ovh application secrets on the user's behalf.

    ## Steps

    - The user needs to set up an ovh account at https://www.ovh.co.uk/ and retrieve a username (nic-handle) and password.

    - Then the user is prompted to do some activations.

    - Upon completion of activations, the user needs to create an application in the ovh website.

    - Then the user can create an application at `https://eu.api.ovh.com/createApp/` or
      alternatively the user can use this mix task to generate the application:

    ## Example

    Create an app with access to all apis:

        mix ovh --login=<username-ovh> --password=<password> --appname='ex_ovh'

    Output:

        config :ex_ovh,
          ovh: [
            application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
            application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
            consumer_key: System.get_env("EX_OVH_CONSUMER_KEY"),
            endpoint: "ovh-eu",
            api_version: "1.0"
          ],
          httpoison: [ # optional
            connect_timeout: 20000,
            receive_timeout: 100000
          ]

    See the [mix task basic](https://hexdocs.pm/ex_ovh/doc/mix_task_basic.md.html) or
    [mix task advanced](https://hexdocs.pm/ex_ovh/doc/mix_task_advanced.md.html) for practical steps involved in running the hubic mix task.
    """
  end

end