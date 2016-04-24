use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :error

config :ex_ovh,
  ovh: %{
    application_key: System.get_env("EX_OVH_APPLICATION_KEY"),
    application_secret: System.get_env("EX_OVH_APPLICATION_SECRET"),
    consumer_key: System.get_env("EX_OVH_CONSUMER_KEY"),
    endpoint: System.get_env("EX_OVH_ENDPOINT"),
    api_version: System.get_env("EX_OVH_API_VERSION") || "1.0",
    connect_timeout: 30000, # 30 seconds
    connect_timeout: (60000 * 30) # 30 minutes
  }