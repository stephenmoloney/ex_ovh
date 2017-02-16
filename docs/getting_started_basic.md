# Getting Started (Basic)

The basic installation is intended for use cases where only a single client is required
on a given server.

#### Installation 

- Add `:ex_ovh` to the dependencies.

```elixir
defp deps() do
  [{:ex_ovh, "~> 0.1.0"}]
end
```

#### `OVH` Configuration

- Create an OVH account at [OVH](https://www.ovh.com/us/)

- Create an API application at the [OVH API page](https://eu.api.ovh.com/createApp/). Follow the
  steps outlined by OVH there.

- Add the configuration settings for the OVH application to your project `config.exs`. The following
environment variables should be set:

    - `EX_OVH_APPLICATION_KEY`
    - `EX_OVH_APPLICATION_SECRET`
    - `EX_OVH_CONSUMER_KEY`

- Set them by adding them to the `.env` file. It's best not to share `.env` so run
echo '.env' >> .gitignore` for the git repository to ensure it doesn't get added to source control.

The `.env` file will be similar to as follows:
```
#!/usr/bin/env bash

# updated on 16.2.2017
export MY_APP_OVH_CLIENT_APPLICATION_KEY="<application_key>"
export MY_APP_OVH_CLIENT_APPLICATION_SECRET="<application_secret>"
export MY_APP_OVH_CLIENT_CONSUMER_KEY="<application_consumer_key>"
```

- If all of the above seems like too much work, then there is a mix task to help generate the application, see
[basic mix task](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task_basic.md) or
[advanced mix task](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task_advanced.md)



#### Some useful requests in the `OVH console` to see applications

- `GET /me/api/application` -- returns a list of application ids.
- `GET /me/api/application/{applicationId}` -- returns json with application key.


#### Creating the appropriate `config.exs` file.

```elixir
config :ex_ovh,
  ovh: [
    application_key: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_KEY"),
    application_secret: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_SECRET"),
    consumer_key: System.get_env("MY_APP_OVH_CLIENT_CONSUMER_KEY")
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

- Now you are read to use the api, open up an `iex` console and give it a try.

```
iex -S mix
```
ExOvh.
```

