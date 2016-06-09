# ExOvh [![Build Status](https://travis-ci.org/stephenmoloney/ex_ovh.svg)](https://travis-ci.org/stephenmoloney/ex_ovh) [![Hex Version](http://img.shields.io/hexpm/v/ex_ovh.svg?style=flat)](https://hex.pm/packages/ex_ovh) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_ovh)

ExOvh is an helper library for the [elixir language](http://elixir-lang.org/) for the [Ovh Api](https://api.ovh.com/).

To use the Openstack components of the OVH API, see [Openstex](https://github.com/stephenmoloney/openstex)


## Project Features

- Config supervised Agent running in the background which stores frequently accessed authentication information.
- Query modules for making building requests to the [Ovh Api](https://api.ovh.com/).
- request functions to send Queries to the [Ovh Api](https://api.ovh.com/).


## Documentation

- [See Hex Docs](https://hexdocs.pm/ex_ovh)

## Getting started

#### Example (1)

| Step 1: Generating the OVH application | Step 2: Setup |
|---|---|
| [Mix Task](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task_basic.md) (optional) | [Setting up the Client](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/getting_started_basic.md) |

#### Example (2) - Recommended way of getting started

| Step 1: Generating the OVH application | Step 2: Setup |
|---|---|
| [Mix Task](https://github.com/stephenmoloney/ex_ovh/blob/master/docs/mix_task_advanced.md) (optional) | [Setting up Clients](https://hexdocs.pm/ex_ovh/blob/master/docs/getting_started_advanced.md) |


## Usage

- To be added


## Issues, Bug Reports, Feature Requests, Suggestions, Guidance, etc
- Create [issues here](https://github.com/stephenmoloney/ex_ovh/issues/new) to communicate your ideas to me. Thanks. 


## Contributing
- Pull requests welcome.


## Tests

- Tests against the OVH portion of the library have not been written yet.


## TODO

- [ ] Tests for OVH portion of library
- [ ] Option to set the application ttl when running ovh mix task.
- [ ] Add queries for the remainder of the OVH API. (Webstorage CDN and Cloud are the only ones covered so far)


## Note 

This is an unofficial client to the OVH api and is not maintained by OVH.


## Licence 

[MIT Licence](LICENSE.txt)
