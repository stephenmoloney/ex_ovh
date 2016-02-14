# ExOvh

ExOvh is an elixir library to make it easier to interact with both the [Ovh](https://api.ovh.com/) api 
and the [Hubic](https://api.hubic.com/) api.

## Note

This repository is a work in progress.




## TODO list


- [ ] *Needed* - generate hex docs
- [ ] *Needed* - generate release and publish to hex packages
- [ ] *Needed* - add proper readme file
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
