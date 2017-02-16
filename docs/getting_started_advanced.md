# Getting Started

## Installation 

- Add `:ex_ovh` to the dependencies.

```elixir
defp deps() do
  [{:ex_ovh, "~> 0.2"}]
end
```

## Configuration

*Note:* The configuration assumes that the environment variables such as `MY_APP_OVH_CLIENT_CLIENT_ID` are already created.

- Create an OVH account at [OVH](https://www.ovh.com/us/)

- Create an API application at the [OVH API page](https://eu.api.ovh.com/createApp/). Follow the
  steps outlined by OVH there. Alternatively, there is a [mix task](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task_advanced.md) which can help
  generate the OVH application.
  
- Add the configuration settings for the OVH application to your project `config.exs`.

```elixir
config :my_app, MyApp.OvhClient,
   ovh: [
     application_key: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_KEY"),
     application_secret: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_SECRET"),
     consumer_key: System.get_env("MY_APP_OVH_CLIENT_CONSUMER_KEY"),
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
defmodule MyApp.OvhClient do
  @moduledoc :false
  use ExOvh.Client, otp_app: :my_app, client: __MODULE__
end
```

- Add the client as a supervisor directly to the supervision tree of your application.

```elixir
def start(_type, _args) do
  import Supervisor.Spec, warn: false
  spec1 = [supervisor(MyApp.Endpoint, [])]
  spec2 = [supervisor(MyApp.OvhClient, [])]
  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(spec1 ++ spec2, opts)
end
```