# ExOvh [![Build Status](https://travis-ci.org/stephenmoloney/ex_ovh.svg)](https://travis-ci.org/stephenmoloney/ex_ovh) [![Hex Version](http://img.shields.io/hexpm/v/ex_ovh.svg?style=flat)](https://hex.pm/packages/ex_ovh) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_ovh)

ExOvh is an helper library in the [elixir language](http://elixir-lang.org/) for the [Ovh Api](https://api.ovh.com/).


## Project Features

- Cache modules (genservers) running in the background which store frequently accessed authentication information.
- Query modules for making calls to the OVH API.


## Documentation

- [hex package manager](https://hexdocs.pm/ex_hubic/api-reference.html).

## Getting started
  
- For setting a single `ExOvh` client, see [getting started basic](https://github.com/stephenmoloney/ex_ovh/docs/getting_started_basic.md.html)
and [mix_task_basic.md](https://github.com/stephenmoloney/ex_ovh/docs/getting_started_basic.md).
- For setting up multiple clients, see [getting started advanced](https://hexdocs.pm/ex_ovh/doc/getting_started_advanced.md) and
[mix_task_advanced.md](https://github.com/stephenmoloney/ex_ovh/docs/getting_started_advanced.md).

## Examples

- to be added


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

MIT
