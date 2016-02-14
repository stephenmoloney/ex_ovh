# ExOvh
ExOvh is an elixir library to make it easier to interact with both the [Ovh Api](https://api.ovh.com/) 
and the [Hubic Api](https://api.hubic.com/).

## Note

This repository is a work in progress.


## Project Features 
- Provides Query modules that enable the easy generation of ovh and hubic related api queries for use by HTTPotion.
- Provides Caches which are modules handling the authentication tokens in the background within a supervision tree.
- Add more here....


## Getting Started


### Hubic  

Create a hubic account. 

Create a hubic application.
    
With the credentials, get the refresh_token. Use the Mix hubic task to 
help generate the refresh token on your behalf if you wish: 


  ```shell
  mix hubic
  --login=<login>
  --password=<password>
  --clientid=<client_id>
  --clientsecret=<client_secret>
  --redirecturi=<uri>
  ```

  
Shell Output
  
  ```elixir
  %{
  client_id: "<client_id>",
  client_secret: "<client_secret>",
  refresh_token: "<refresh_token>",
  redirect_uri: "<uri>"
  }
  ```

Add the hubic credentials printed in the shell by the mix hubic task to the `config/prod.secret.exs` file

  ```
  config :ex_ovh,
    ovh: :nil
    hubic:   %{
              client_id: "<client_id>",
              client_secret: "<client_secret>",
              refresh_token: "<refresh_token>",
              redirect_uri: "<uri>"
             }
  ```

### OVH


Create an OVH account 

Create an application at `https://eu.api.ovh.com/createApp/` or
alternatively use the mix ovh task to generate the application:


  ```shell
  mix ovh
  --login=<username>
  --password=<password>
  --appname='My app'
  --appdesc='my app for api'
  --accessrules='get-[/*]::put-[/me,/cdn]::post-[/me,/cdn]::delete-[]'
  ```

As seen above, access rules can be specified so that only certain endpoints are allowed.

Shell Output

  A map is printed to the shell as follows:

  ```elixir
  %{
  application_key: "<app_key>",
  application_secret: "<app_secret>",
  consumer_key: "<consumer_secret>",
  endpoint: "ovh-eu",
  api_version: "1.0"
  }
  ```

  - This map can then be manually added by the user to the `config/prod.secret.exs` file

  ```
  config :ex_ovh,
  ovh: %{
        application_key: "<app_key>",
        application_secret: "<app_secret>",
        consumer_key: "<consumer_secret>",
        endpoint: "ovh-eu",
        api_version: "1.0"
       },
  hubic: %{
          client_id: "<client_id>",
          client_secret: "<client_secret>",
          refresh_token: "<refresh_token>",
          redirect_uri: "<uri>"
         }
  ```

### Starting the supervisor

Add the supervisor to your supervision tree:
 
 ```elixir 
   def start(_type, _args) do
    import Supervisor.Spec, warn: false

    phoenix = [supervisor(TestOs.Endpoint, [])]
    ex_ovh = [supervisor(ExOvh, [])]

    opts = [strategy: :one_for_one, name: TestOs.Supervisor]
    Supervisor.start_link(phoenix ++ ex_ovh  ++ child3, opts)
  end
  ```

# SHOW HOW TO ADD ANOTHER CLIENT HERE .... LATER.....


## Example Usage(s)


### Example 1: Creating a new container in hubic

  ```elixir
  import ExOvh.Query.Openstack.Swift
  alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
  client = ExOvh
  account = OpenCache.get_account(client)
  ExOvh.hubic_request(create_container(account, "new_container"), %{ openstack: :true })
  ```



# TO BE CONTINUED..... LATER ....



## Issues, Bug Reports, Feature Requests, Suggestions, Guidance, etc
- Create [issues here](https://github.com/stephenmoloney/ex_ovh/issues/new) to communicate your ideas to me. Thanks. 



## Contributing
- Pull requests welcome.



## Tests

*Warning* No tests have been performed or added yet. This is on my radar.


## Potential TODO list


- [ ] *Needed* - generate hex docs
- [ ] *Needed* - generate release and publish to hex packages
- [ ] *Needed* - *Tests* - add basic tests for most api calls.
- [ ] *Needed* - *Tests* - verify the supervisor chain, genservers and genserver naming is working ok.

 
- [ ] *Maybe* - investigate ways to add sensitive keys, secrets, etc to system env and allow the config.exs to get variables from `System`.
- [ ] *Maybe* - improve error handling for unexpected responses if possible - hard to find good documentation for expected error responses.
- [ ] *Maybe* - add a time to live configuration for the validity period of the ovh credential token
- [ ] *Maybe* - Add some further validations during the mix tasks.
- [ ] *Maybe* - Add request helper functions to create folders in the hubic api.



## Note 

This is an unofficial client to the OVH api and is not maintained by OVH.


## Licence 

MIT
