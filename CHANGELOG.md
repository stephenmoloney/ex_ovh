# Changelog

## v0.2

[enhancements]
- Update some dependencies
- Update mix task so that it will handle activated 2FA on OVH accounts
- Simplify the readme documentation

[bug fixes]
- Fix bug in mix task causing it to fail
- Fix bug in ex_ovh config file where list could not be printed inside "#{}" - causing application to crash

[neutral changes]
- Merge docs back into the original module files

## v0.1.3

- Improve the `mix ovh` docs to better illustrate how to create an application and setup access rules.

## v0.1.2

- Fix `mix ovh` task.
- Fix some of the `/cloud` queries (binary key was missing due to missed earlier change)


## v0.1.1

- No changes to source code. Only documentation changes.


## v0.1.0

- Decouple the `Openstack` component into the `Openstex` repository.
Only requests to the `ExOvh` API can be made with `ExOvh`.
- Add documentation.
- Remove no longer used dependency `:secure_random`.


## v0.0.1

- Initial release.