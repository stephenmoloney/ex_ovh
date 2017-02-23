# Changelog


## v0.3.0

[changes]
- Update some dependencies
- Relax versioning of some dependencies
- Include `mix.lock` in version control
- Add new file `docs/usage.md` with examples on using the api
- Remove dependency on `morph` - use `Macro.underscore` instead.
- Reduce depency base - use `:hackney` only
- remove `Cloud.Cloudstorage` module and place all functions in `Cloud` module ***(breaking change)***
- change naming of various modules to reduce length ***(breaking change)***
- change the docs to reflect the move to [httpipe](https://hex.pm/packages/httpipe)
- with the use of [httpipe](https://hex.pm/packages/httpipe), the abstraction changes from `Query` to `Request` -
this is essentially a name change only.

[enhancements]
- Use [httpipe](https://hex.pm/packages/httpipe) and the corresponding hackney adapter.
- Remove the abstractions based on `Query` and `HTTPQuery` and in it's place use a similar abstraction
in the third party library [httpipe](https://hex.pm/packages/httpipe)


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