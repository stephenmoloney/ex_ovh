# ExOvh
ExOvh is an elixir library for the [Ovh Api](https://api.ovh.com/).


## Project Features

- Cache modules (genservers) running in the background which store frequently accessed authentication information.
- Query and Helper modules for making calls to the OVH API.
- Query and Helper modules for making calls to the Openstack Swift API. OVH uses openstack for their [webstorage cdn service](https://www.ovh.ie/cdn/webstorage/)
and their [public cloud storage service](https://www.ovh.ie/cloud/storage/)


## Getting Started

- Add :ex_ovh to the dependencies.

  ```elixir
  defp deps() do
    [
      {:ex_ovh, "~> 0.0.1"}
    ]
  end
  ```

- Create an OVH account at [OVH](https://www.ovh.com/us/)

- Create an API application at the [OVH API page](https://eu.api.ovh.com/createApp/). Follow the
  steps outlined by OVH there. This is the correct way to create the OVH application.

- Alternatively, there is a mix task which:

    1. Creates an application on the user's behalf by sending http requests using the user's username and password credentials.
    2. Gets a consumer key and validation url.
    3. Validates the validation url on the user's behalf by sending http requests using the user's username and password credentials.
    4. Adds the application key, application secret and associated consumer key to the environment configuration.

- Examples using the mix ovh task:

  - Most basic usage:

  **Shell Input:**
  ```shell
  mix ovh \
  --login=<username-ovh> \
  --password=<password> \
  --appname='ex_ovh'
  ```

  - `login`: username/nic_handle for logging into OVH services. *Note*: must include `-ovh` at the end of the string.
  - `password`: password for logging into OVH services.
  - `appname`: this should correspond to the `otp_app` name in the elixir application. The same name will be used as
  the name for the application in OVH.
  - `redirecturi`: defaults to `""` when absent.
  - `endpoint`: defaults to `"ovh-eu"` wen absent.
  - `accessrules`: defaults to `get-[/*]::put-[/*]::post-[/*]::delete-[/*]` when absent giving the application all
    full priveleges. One may consider fine-tuning the accessrules, see advanced example below.
  - `appdescription`: defaults to `appname` if absent
  - `clientname`:" defaults to `ExOvh` when the appname is exactly equal to `ex_ovh`, otherwise defaults to `OvhClient`.

  **Shell Output:**

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
  This configuration can be added to `config.exs`.

  - `EX_OVH_APPLICATION_KEY`: The system environment variable name for the application key.
  - `EX_OVH_APPLICATION_SECRET`: The system environment variable name for the application secret.
  - `EX_OVH_CONSUMER_KEY`: The system environment variable name for the consumer key.
  - `EX_OVH_ENDPOINT`: The system environment variable name for the ovh endpoint.
  - `EX_OVH_API_VERSION`: The system environment variable name for the api version.


  - The enviroment variables are saved to a file called `.env` automatically by the mix task.
  **Do not add the `.env` file to version control.** Add the variables to the system environment
  by running the command or some other commands as appropriate to the deployment method.

  ```shell
  source .env
  ```

  - Advanced usage:

  **Shell Input:**

  ```shell
  mix ovh \
  --login=<username-ovh> \
  --password=<password> \
  --appdescription='Ovh Application for my app' \
  --endpoint='ovh-eu' \
  --apiversion='1.0' \
  --redirecturi='http://localhost:4000/' \
  --accessrules='get-[/*]::put-[/me,/cdn]::post-[/me,/cdn]::delete-[]' \
  --appname='my_app'
  --clientname='OvhClient'
  ```

  - `login`: username/nic_handle for logging into OVH services. *Note*: must include `-ovh` at the end of the string.
  - `password`: password for logging into OVH services.
  - `appname`: appname corresponds to the `otp_app` name in the elixir application. The same name will be used as
  the name for the application in OVH.
  - `clientname`:" defaults to `ExOvh` when the appname is exactly equal to `ex_ovh`, otherwise defaults to `OvhClient`. `clientname` corresponds to the name of the client. So for example, if appname is `'my_app'` and clientname is
    `'Client'` then the config file will be `config :my_app, MyApp.Client`. Also, the client in application code can be referred
    to as `MyApp.Client.function_name`.
  - `appdescription`: A description for the application saved to OVH.
  - `endpoint`: OVH endpoint to be used. May vary depending on the OVH service. See `ExOvh.Ovh.Defaults`.
  - `apiversion`: version of the api to use. Only one version available currently.
  - `redirecturi`: redirect url for oauth authentication. Should be https.
  - `accessrules`: restrictions can be added to the access rules. In this example, `get` requests to all endpoints are allowed,
    `put` and `post` requests to `/me` and `/cdn` and `delete` requests are forbidden.


  **Shell Output:**

  ```elixir
  config :my_app, MyApp.OvhClient,
      ovh: [
        application_key: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_KEY"),
        application_secret: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_SECRET"),
        consumer_key: System.get_env("MY_APP_OVH_CLIENT_CONSUMER_KEY"),
        endpoint: System.get_env("MY_APP_OVH_CLIENT_ENDPOINT"),
        api_version: System.get_env("MY_APP_OVH_CLIENT_API_VERSION") || "1.0"
      ]
  ```
  This configuration can be added to `config.exs`.

  - `EX_OVH_APPLICATION_KEY`: The system environment variable name for the application key.
  - `EX_OVH_APPLICATION_SECRET`: The system environment variable name for the application secret.
  - `EX_OVH_CONSUMER_KEY`: The system environment variable name for the consumer key.
  - `EX_OVH_ENDPOINT`: The system environment variable name for the ovh endpoint.
  - `EX_OVH_API_VERSION`: The system environment variable name for the api version.


  - The enviroment variables are saved to a file called `.env` automatically by the mix task.
  **Do not add the `.env` file to version control.** Add the variables to the system environment
  by running the command or some other commands as appropriate to the deployment method.

  ```shell
  source .env
  ```

- Make further configurations if necessary, depending on which OVH services are being used.

  - Configuration for [webstorage cdn service](https://www.ovh.ie/cdn/webstorage/)

  In the example below, `EX_OVH_WEBSTORAGE_CDN_NAME` is added to the environment variables.
  ```elixir
  config :ex_ovh,
    ovh: [],
    swift: [
          webstorage: [
                        cdn_name: System.get_env("MY_APP_OVH_CLIENT_WEBSTORAGE_CDN_NAME"),
                        type: :webstorage
                      ]
         ]
   ```

  - Configuration for public cloud storage service](https://www.ovh.ie/cloud/storage/)

  In the example below, `MY_APP_OVH_CLIENT_CLOUDSTORAGE_TENANT_ID` and `MY_APP_OVH_CLIENT_CLOUDSTORAGE_USER_ID` are
  added to the environment variables.
  ```elixir
  config :ex_ovh,
    ovh: [],
    swift: [
          cloudstorage: [
                          tenant_id: System.get_env("MY_APP_OVH_CLIENT_CLOUDSTORAGE_TENANT_ID"), # mandatory, corresponds to a project id
                          user_id: System.get_env("MY_APP_OVH_CLIENT_CLOUDSTORAGE_USER_ID"), # optional, if absent a user will be created using the ovh api.
                          keystone_endpoint: "https://auth.cloud.ovh.net/v2.0", # default endpoint for keystone (identity) auth
                          region: :nil, # defaults to "SBG1" if set to :nil
                          type: :cloudstorage
                        ]
         ]
   ```

- Optionally configure `:openstex` which allows customization of [httpoison opts](https://github.com/edgurgel/httpoison/blob/master/lib/httpoison/base.ex#L127)
  for each request.

  Example configuration for custom [httpoison opts](https://github.com/edgurgel/httpoison/blob/master/lib/httpoison/base.ex#L127) (optional):
  ```elixir
  config :openstex,
    httpoison: [
                connect_timeout: 30000, # 30 seconds
                receive_timeout: (60000 * 30) # 30 minutes
               ]
  ```

- The final phase of configuration is to set up the supervision tree. There are effectively two ways to do
  this:

    1. The 'correct way' where a client is setup for the otp_app, therefore allowing for the creation of
       multiple clients.

       Example configuration:

       ```elixir
       config :my_app, MyApp.OvhClient,
           ovh: [
             application_key: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_KEY"),
             application_secret: System.get_env("MY_APP_OVH_CLIENT_APPLICATION_SECRET"),
             consumer_key: System.get_env("MY_APP_OVH_CLIENT_CONSUMER_KEY"),
             endpoint: System.get_env("MY_APP_OVH_CLIENT_ENDPOINT"),
             api_version: System.get_env("MY_APP_OVH_CLIENT_API_VERSION") || "1.0"
           ]
       ```

       Add supervisors to the supervision tree of the application, for example:

       ```elixir
       def start(_type, _args) do
        import Supervisor.Spec, warn: false
        spec1 = [supervisor(MyApp.Endpoint, [])]
        spec2 = [supervisor(MyApp.OvhClient, [])]
        opts = [strategy: :one_for_one, name: MyApp.Supervisor]
        Supervisor.start_link(spec1 ++ spec2, opts)
       end
       ```

    2. The 'quick way' which is quite useful when only one client is needed.

       Example Configuration:

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

       Then simply add the application to the project applications list. The supervision
       tree is then started from the application level.

       ```elixir
       def application do
         [
         applications: [:ex_ovh]
         ]
       end
       ```


## Examples


Get account details and containers for given account
``` ```

Creating a new container
``` ```

Get the container count
``` ```

Adding an object to the "default" container in [OVH CDN Webstorage](https://www.ovh.ie/cdn/webstorage/)
``` ```

Listing all objects for "default" container in [OVH CDN Webstorage](https://www.ovh.ie/cdn/webstorage/)
``` ```



## Issues, Bug Reports, Feature Requests, Suggestions, Guidance, etc
- Create [issues here](https://github.com/stephenmoloney/ex_ovh/issues/new) to communicate your ideas to me. Thanks. 



## Contributing
- Pull requests welcome.



## Tests

*Warning* No tests have been performed or added yet. This is on my radar.


## Potential TODO list


- [ ] *Needed* - generate hex docs
- [ ] *Needed* - generate release and publish to hex packages
- [ ] *Needed* - Tests
- [ ] *Maybe* - Option to set the application ttl when running ovh mix task.


## Note 

This is an unofficial client to the OVH api and is not maintained by OVH.


## Licence 

MIT
