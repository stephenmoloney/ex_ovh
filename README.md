# ExOvh [![Build Status](https://travis-ci.org/stephenmoloney/ex_ovh.svg)](https://travis-ci.org/stephenmoloney/ex_ovh) [![Hex Version](http://img.shields.io/hexpm/v/ex_ovh.svg?style=flat)](https://hex.pm/packages/ex_ovh) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_ovh) [![Deps Status](https://beta.hexfaktor.org/badge/prod/github/stephenmoloney/ex_ovh.svg)](https://beta.hexfaktor.org/github/stephenmoloney/ex_ovh)


ExOvh is an helper library for the [elixir language](http://elixir-lang.org/) for the [Ovh Api](https://api.ovh.com/).
To use the Openstack components of the OVH API, see [Openstex](https://github.com/stephenmoloney/openstex)


#### Project Features

- Config supervised agent running in the background which stores frequently accessed authentication information.
- Query modules for making building requests to the [Ovh Api](https://api.ovh.com/).
- Request functions to send Queries to the [Ovh Api](https://api.ovh.com/).


#### Getting started - Step 1: Generating the OVH `application key`, `application secret` and `consumer key`.

- This may be done manually by going to `https://eu.api.ovh.com/createApp/` and following the directions outlined by `OVH` at
[their first steps guide](https://api.ovh.com/g934.first_step_with_api).

- Alternatively, this may be achieved by running a mix task. This saves me a lot of time when generating a new application.

- [Documentation here](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task.md)


#### Getting Started - Step 2: Generating the OVH client module for your elixir application

- The client module (eg `AwesomeApp.OvhClient`) is the interface for accessing the
functions of the ***ex_ovh*** `API`.

- [Documentation here](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/getting_started.md)


#### Usage

#### Examples - Method 1 - Building the queries manually and send the request (my preferred way)


- `GET /me`
```
%ExOvh.Query{headers: [], method: :get, params: %{}, service: :ovh, uri: "/me"} \
|> MyApp.OvhClient.request!()
```

- `GET /me/api/application`
```
%ExOvh.Query{headers: [], method: :get, params: %{}, service: :ovh, uri: "/me/api/application"} \
|> MyApp.OvhClient.request!()
```

- `GET /me/api/application/#{app_id}`
```
app_id = "0"
%ExOvh.Query{headers: [], method: :get, params: %{}, service: :ovh, uri: "/me/api/application/#{app_id}"} \
|> MyApp.OvhClient.request!()
```

- `GET /cloud/project/{serviceName}/storage`
```
service_name = "service_name" \
%ExOvh.Query{headers: [], method: :get, params: %{}, service: :ovh, uri: "/cloud/project/#{service_name}/storage"} \
MyApp.OvhClient.request!()
```


#### Examples - Method 2 - Build the query using provided helper functions and send the request

***Note:*** The Helper functions are listed under `Services`. Helper functions are only available currently for the
`/Cloud` portion of the OVH API. Where other parts of the api need to be queried, just build the query manually
using *Method 1* as above. Pull requests for helper functions for other parts of the OVH API are welcome.
*Eventually, I would like to write a macro to create the queries.*

- `GET /cloud/project/{serviceName}/storage`
```
ExOvh.Services.V1.Cloud.Cloudstorage.Query.get_containers(service_name) \
|> ExOvh.request!()
```

- For more information [See Hex Docs](https://hexdocs.pm/ex_ovh/0.2/api-reference.html)


#### Contributing

- Pull requests welcome.


#### Tests

- Tests have not been written yet.


#### TODO

- [ ] Tests for OVH portion of library
- [ ] Option to set the application ttl when running ovh mix task.
- [ ] Add queries for the remainder of the OVH API. (Webstorage CDN and Cloud are the only ones covered so far)
- [ ] Basic examples to be added to readme of usage of the api.
- [ ] Add macro for building queries.
- [ ] Write the usage guide - more examples of using the API.


#### Note 

This is an unofficial client to the OVH api and is not maintained by OVH.


#### Licence 

[MIT Licence](LICENCE.md)