# Getting Started (Basic)

The basic installation is intended for use cases where only a single client is required
on a given server.

## Installation 

- Add `:ex_ovh` to the dependencies.

```elixir
defp deps() do
  [{:ex_ovh, "~> 0.0.1"}]
end
```

## Configuration

*Note:* The configuration assumes that the environment variables such as `EX_OVH_CLIENT_ID` are already created.

- Create an OVH account at [OVH](https://www.ovh.com/us/)

- Create an API application at the [OVH API page](https://eu.api.ovh.com/createApp/). Follow the
  steps outlined by OVH there. Alternatively, there is a [mix task](https://hexdocs.pm/ex_hubic/doc/mix_task_advanced.md.html) which can help 
  generate the OVH application.
  
- Add the configuration settings for the OVH application to your project `config.exs`.

```elixir
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
```

- Start the `ExOvh` application.

```elixir
def application do
 [applications: [:ex_ovh]]
end
```

- Add the client to your project.

```elixir
defmodule ExOvh do
  @moduledoc :false
  use ExOvh.Client, otp_app: :my_app, client: __MODULE__
end
```

- Add the `ExOvh` client to the supervision tree of your application.

```elixir
def start(_type, _args) do
  import Supervisor.Spec, warn: false
  spec1 = [supervisor(MyApp.Endpoint, [])]
  spec2 = [supervisor(ExOvh, [])]
  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(spec1 ++ spec2, opts)
end
```

