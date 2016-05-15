# ExOvh [![Build Status](https://travis-ci.org/stephenmoloney/ex_ovh.svg)](https://travis-ci.org/stephenmoloney/ex_ovh) [![Hex Version](http://img.shields.io/hexpm/v/ex_ovh.svg?style=flat)](https://hex.pm/packages/ex_ovh) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_ovh)

ExOvh is an helper library in the [elixir language](http://elixir-lang.org/) for the [Ovh Api](https://api.ovh.com/).


## Project Features

- Cache modules (genservers) running in the background which store frequently accessed authentication information.
- Query and Helper modules for making calls to the OVH API.
- Query and Helper modules for making calls to the Openstack Swift API. OVH uses openstack for their [webstorage cdn service](https://www.ovh.ie/cdn/webstorage/)
and their [public cloud storage service](https://www.ovh.ie/cloud/storage/)


## Documentation

- [hex package manager](https://hexdocs.pm/ex_hubic/api-reference.html).

## Getting started
  
- For setting up just one `ExHubic` client, see [getting started basic](https://hexdocs.pm/ex_hubic/doc/getting_started_basic.md.html).
- Setting up a custom client or multiple clients, see [getting started advanced](https://hexdocs.pm/ex_hubic/doc/getting_started_advanced.md.html) *(recommended method)*.

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

- Tests against the Swift portion of the library are carried out in the [Openstex library](https://github.com/stephenmoloney/openstex).
- Tests against the OVH portion of the library have not been written yet.


## TODO

- [ ] Tests for OVH portion of library
- [ ] Option to set the application ttl when running ovh mix task.
- [ ] Add queries for the remainder of the OVH API. (Webstorage CDN and Cloud are the only ones covered so far)


## Note 

This is an unofficial client to the OVH api and is not maintained by OVH.


## Licence 

MIT
