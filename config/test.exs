use Mix.Config


config :logger,
  backends: [:console],
  compile_time_purge_level: :error


config :ex_ovh,
  ovh: [
    application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
    application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
    consumer_key: System.get_env("EX_OVH_CONSUMER_KEY"),
    endpoint: System.get_env("EX_OVH_ENDPOINT"),
    api_version: System.get_env("EX_OVH_API_VERSION") || "1.0"
  ],
  swift: [
          webstorage: [
                        cdn_name: System.get_env("EX_OVH_WEBSTORAGE_CDN_NAME"),
                        type: :webstorage
                      ],
          cloudstorage: [
                          tenant_id: System.get_env("EX_OVH_CLOUDSTORAGE_TENANT_ID"), # mandatory, corresponds to a project id
                          user_id: System.get_env("EX_OVH_CLOUDSTORAGE_USER_ID"), # optional, if absent a user will be created using the ovh api.
                          keystone_endpoint: "https://auth.cloud.ovh.net/v2.0", # default endpoint for keystone (identity) auth
                          region: :nil, # defaults to "SBG1" if set to :nil
                          type: :cloudstorage
                        ]
         ]