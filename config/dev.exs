use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug


config :openstex,
  httpoison: [
              connect_timeout: 30000, # 30 seconds
              receive_timeout: (60000 * 30) # 30 minutes
             ]


config :ex_ovh,
  ovh: [
    application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
    application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
    consumer_key: System.get_env("EX_OVH_CONSUMER_KEY"),
    endpoint: System.get_env("EX_OVH_ENDPOINT"),
    api_version: System.get_env("EX_OVH_API_VERSION") || "1.0"
  ],
  swift: [
          webstorage: [ #  <-- :webstorage will be the config_id
                        cdn_name: System.get_env("EX_OVH_WEBSTORAGE_CDN_NAME"),
                        type: :webstorage
                      ],
          cloudstorage: [ #  <-- :cloudstorage will be the config_id
                          tenant_id: System.get_env("EX_OVH_CLOUDSTORAGE_TENANT_ID"), # mandatory, corresponds to a project id
                          user_id: System.get_env("EX_OVH_CLOUDSTORAGE_USER_ID"), # optional, if absent a user will be created using the ovh api.
                          endpoint: "https://auth.cloud.ovh.net/v2.0",
                          region: :nil, # defaults to "SBG1" if set to :nil
                          type: :cloudstorage
                        ]
         ]




#config :my_app, MyApp.ExOvhClient1,
#  ... then as above

# SAMPLE CONFIGURATIONS ON A PER APP AND PER API BASIS FOR OPENSTEX

#config :my_app, MyApp.ExOvhClient1.Ovh, <-- For OVH part of the api
#  httpoison: ... as above

#config :my_app, MyApp.ExOvhClient1.Swift.Webstorage, <-- For Openstack Webstorage part of the api
#  httpoison: ... as above

#config :my_app, MyApp.ExOvhClient1.Swift.Cloudstorage, <-- <-- For Openstack Cloudstorage part of the api
#  httpoison: ... as above
