# Getting Started (Basic)

## Installation 

- Add `:ex_ovh` to the dependencies.

```elixir
defp deps() do
  [{:ex_ovh, "~> 0.0.1"}]
end
```
  
- Start `ExOvh` application which in makes `ExOvh` client ready for use.

```elixir
def application do
 [applications: [:ex_ovh]]
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
    endpoint: System.get_env("EX_OVH_ENDPOINT"),
    api_version: System.get_env("EX_OVH_API_VERSION") || "1.0"
  ]
```

- Make further configurations if necessary, depending on which OVH services are being used.

- Configuration for [webstorage cdn service](https://www.ovh.ie/cdn/webstorage/)

In the example below, `EX_OVH_WEBSTORAGE_CDN_NAME` is added to the environment variables.

```elixir
config :ex_ovh,
  ovh: [],
  swift: [
        webstorage: [
                      cdn_name: System.get_env("EX_OVH_WEBSTORAGE_CDN_NAME"),
                      type: :webstorage
                    ]
       ]
```

- Configuration for public cloud storage service](https://www.ovh.ie/cloud/storage/)

In the example below, `EX_OVH_CLOUDSTORAGE_TENANT_ID` and `EX_OVH_CLOUDSTORAGE_USER_ID` are
added to the environment variables.

```elixir
config :ex_ovh,
  ovh: [],
  swift: [
        cloudstorage: [
                        tenant_id: System.get_env("EX_OVH_CLOUDSTORAGE_TENANT_ID"), # mandatory, corresponds to a project id
                        user_id: System.get_env("EX_OVH_CLOUDSTORAGE_USER_ID"), # optional, if absent a user will be created using the ovh api.
                        keystone_endpoint: "https://auth.cloud.ovh.net/v2.0", # default endpoint for keystone (identity) auth
                        region: :nil, # defaults to "SBG1" if set to :nil
                        type: :cloudstorage
                      ]
       ]
```

- Optionally configure `:openstex` which allows customization of [httpoison opts](https://github.com/edgurgel/httpoison/blob/master/lib/httpoison/base.ex#L127)
for each request. Example configuration for custom [httpoison opts](https://github.com/edgurgel/httpoison/blob/master/lib/httpoison/base.ex#L127) (optional):

```elixir
config :openstex,
  httpoison: [
              connect_timeout: 30000, # 30 seconds
              receive_timeout: (60000 * 30) # 30 minutes
             ]
```