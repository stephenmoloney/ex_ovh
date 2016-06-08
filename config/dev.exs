use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

config :ex_ovh,
  ovh: [
    application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
    application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
    consumer_key: System.get_env("EX_OVH_CONSUMER_KEY")
  ],
  httpoison: [
    connect_timeout: 20000,
    receive_timeout: 180000
  ]