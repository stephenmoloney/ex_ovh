# Getting Started

- This guide assumes your application is called `MyApp`. If your app is called something else, for example `Awesome`,
then substitute `Awesome` for `MyApp` and `AWESOME_OVH_CLIENT_` for `MY_APP_OVH_CLIENT_` everywhere in this guide.


#### Installation

- Add `:ex_ovh` to the dependencies inx `mix.exs`.

```elixir
defp deps() do
  [{:ex_ovh, "~> 0.4"}]
end
```

#### `OVH` configuration

- Create an OVH account at [OVH](https://www.ovh.com/us/)

- Create an API application at the [OVH API page](https://eu.api.ovh.com/createApp/). Follow the
  steps outlined by OVH there.

- Add the configuration settings for the OVH application to the project `config.exs`. The following
environment variables should be set:

    - `MY_APP_OVH_CLIENT_APPLICATION_KEY`
    - `MY_APP_OVH_CLIENT_APPLICATION_KEY`
    - `MY_APP_OVH_CLIENT_APPLICATION_KEY`

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
[mix task docs](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task.md).


#### Creating a client module

***NOTE:*** Matching naming between `MyApp.OvhClient` and `MY_APP_OVH_CLIENT_APPLICATION_KEY` variables is expected.

- Basic settings

  ```elixir
  config :my_app, MyApp.OvhClient,
     ovh: [
       application_key: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_KEY"),
       application_secret: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_SECRET"),
       consumer_key: System.get_env("MY_APP_OVH_CLIENT_CONSUMER_KEY"),
     ]
  ```

- More elaborate settings

  ```elixir
  config :my_app, MyApp.OvhClient,
     ovh: [
       application_key: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_KEY"),
       application_secret: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_SECRET"),
       consumer_key: System.get_env("MY_APP_OVH_CLIENT_CONSUMER_KEY"),
       endpoint: "ovh-eu",
       api_version: "1.0"
     ],
     hackney: [ # optional
       connect_timeout: 20000,
       recv_timeout: 100000
     ]
  ```

#### Starting the `ex_ovh application`

- Add `ex_ovh` to the list of applications so that it is started. Start the `ExOvh` application.

```elixir
def application do
 [applications: [:ex_ovh]]
end
```


#### Create the ovh client module


```elixir
defmodule MyApp.OvhClient do
  @moduledoc :false
  use ExOvh.Client, otp_app: :my_app, client: __MODULE__
end
```

#### Add the client to the application supervision tree

```elixir
def start(_type, _args) do
  import Supervisor.Spec, warn: false
  spec1 = [supervisor(MyApp.Endpoint, [])]
  spec2 = [supervisor(MyApp.OvhClient, [])]
  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(spec1 ++ spec2, opts)
end
```

#### Making requests

- The client `MyApp.OvhClient` is now ready.

- To make requests see example usages below:


#### Example usages

- First start the application with the system environment variables available `source .env && iex -S mix`

- Then try running some requests against the `API`


#### Examples - Method 1 - Building the queries manually and sending the request (my preferred way)


- `GET /me`

```
req = %HTTPipe.Request{
  method: :get,
  url: "/me"
}
|> MyApp.OvhClient.request!()
```

- `GET /me/api/application`

```
req = %HTTPipe.Request{
  method: :get,
  url: "/me/api/application"
}
|> MyApp.OvhClient.request!()
```

- `GET /me/api/application/#{app_id}`

```
app_id = "0"
req = %HTTPipe.Request{
  method: :get,
  url: "/me/api/application/#{app_id}"
}
|> MyApp.OvhClient.request!()
```

- `GET /cloud/project/{serviceName}/storage`

```
service_name = "service_name"
req = %HTTPipe.Request{
  method: :get,
  url: "/cloud/project/#{service_name}/storage"
}
|> MyApp.OvhClient.request!()
```


#### Examples - Method 2 - Build the request using provided helper functions and sending the request

***Note:*** Helper functions are only available currently for the `/Cloud` portion of the OVH API.
*Eventually, I would like to write a macro to create the queries.*

- `GET /cloud/project`

```
ExOvh.V1.Cloud.list_services() |> ExOvh.request!()
```

- `GET /cloud/project/{serviceName}/storage`

```
resp1 = ExOvh.V1.Cloud.list_services() |> ExOvh.request!() |> Map.get(:response) 
service = Map.get(resp1, :body) |> List.last()
resp2 = ExOvh.V1.Cloud.get_containers(service) |> ExOvh.request!() |> Map.get(:response)
containers =  Map.get(resp2, :body)
```


#### Usage guide

- For more usage examples see the usage guide or the [hex documentation](https://hexdocs.pm/ex_ovh/ExOvh.html)