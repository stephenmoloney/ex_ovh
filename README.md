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


### Add :httpotion to applications on startup (httpotion is used for http requests) 

```elixir
  def application do 
    [ 
      applications: [:httpotion]
    ]
  end
```

### Starting the supervisor

Add the supervisor to your supervision tree:
 
 ```elixir 
   def start(_type, _args) do
    import Supervisor.Spec, warn: false

    phoenix = [supervisor(TestOs.Endpoint, [])]
    ex_ovh = [supervisor(ExOvh, [])]

    opts = [strategy: :one_for_one, name: TestOs.Supervisor]
    Supervisor.start_link(phoenix ++ ex_ovh, opts)
  end
  ```


#### Show how to add another client here ......



## Example Usage(s)


### Example 1: 


Get account details and containers for given account
  ```elixir
  alias ExOvh.Query.Openstack.Swift, as: Query
  alias ExOvh.Hubic.OpenstackApi.Cache, as: OpenCache
  client = ExOvh
  
  account = OpenCache.get_account(client)
  query = Query.account_info(account)
  {:ok, resp} = ExOvh.hubic_request(query, %{ openstack: :true })
  container_count1 = resp.body |> Enum.count() 
  ```

Creating a new container in hubic
  ```elixir
  random_container = SecureRandom.base64(8)
  query = Query.create_container(account, random_container)
  ExOvh.hubic_request(query, %{ openstack: :true })
  ```

Get the count of containers again
  ```elixir
  query = Query.account_info(account)
  {:ok, resp} = ExOvh.hubic_request(query, %{ openstack: :true })
  container_count2 = resp.body |> Enum.count()
  container_count1 + 1 == container_count2
  ```
 
 
### Example 2: 


Adding an object to the "default" container in [OVH CDN Webstorage](https://www.ovh.ie/cdn/webstorage/)

    import ExOvh.Query.Openstack.Swift
    alias ExOvh.Ovh.OpenstackApi.Webstorage.Cache, as: OpenCache
    client = ExOvh
    service = "cdnwebstorage-<your_service_name>"
    account = OpenCache.get_account(client, service)
    
    object_name = "client_file.txt"
    client_object = Kernel.to_string(:code.priv_dir(:ex_ovh)) <> "/" <> object_name
    container = "default"
    server_object = String.replace(object_name, "client", "server")
    create_file_request = create_object(account, container, client_object, server_object)
    
    ExOvh.ovh_request(create_file_request, %{ openstack: :true, webstorage: service })


Listing all objects for "default" container to see if the new `server_object` is there in [OVH CDN Webstorage](https://www.ovh.ie/cdn/webstorage/)

    import ExOvh.Query.Openstack.Swift
    alias ExOvh.Ovh.OpenstackApi.Webstorage.Cache, as: OpenCache
    client = ExOvh
    service = "cdnwebstorage-<your_service_name>"
    account = OpenCache.get_account(client, service)
    request = get_objects(account, "default")
    
    {:ok, resp} = ExOvh.ovh_request(request, %{ openstack: :true, webstorage: service })
    objects = Enum.map(resp.body, &(Map.get(&1, "name")))
    
    Enum.member?(objects, server_object)
      

#### Add more examples ....



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
- [ ] *Needed* - *New functions* - ovh and hubic functions with !.

 
- [ ] *Maybe* - investigate ways to add sensitive keys, secrets, etc to system env and allow the config.exs to get variables from `System`.
- [ ] *Maybe* - improve error handling for unexpected responses if possible - hard to find good documentation for expected error responses.
- [ ] *Maybe* - add a time to live configuration for the validity period of the ovh credential token
- [ ] *Maybe* - Add some further validations during the mix tasks.
- [ ] *Maybe* - Add request helper functions to create folders in the hubic api.



## Note 

This is an unofficial client to the OVH api and is not maintained by OVH.


## Licence 

MIT
