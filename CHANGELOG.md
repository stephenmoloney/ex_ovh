# Changelog


## v0.3.2

[changes]
- Add default adapter `hackney` to the mix tasks.

[bug fix]
- Fix setting the query string bug (typo) - `url.encode_query(qs_map)` -> `URI.encode_query(qs_map)`
- Problem with `Body.apply()` being called in the wrong place
- Fix `get_prices` in the `Cloud` Request build functions

[enhancements]
- Add `prepare_request/2` function - prepares the request without sending it. Applies standard transformations.

## v0.3.1

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

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

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

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

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

- Improve the `mix ovh` docs to better illustrate how to create an application and setup access rules.

## v0.1.2

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

- Fix `mix ovh` task.
- Fix some of the `/cloud` queries (binary key was missing due to missed earlier change)


## v0.1.1

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

- No changes to source code. Only documentation changes.


## v0.1.0

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

- Decouple the `Openstack` component into the `Openstex` repository.
Only requests to the `ExOvh` API can be made with `ExOvh`.
- Add documentation.
- Remove no longer used dependency `:secure_random`.


## v0.0.1

***Security Warning: Versions of `ex_ovh` less than `0.3.2` are deprecated and should not be used
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` or above of `ex_ovh` instead***

- Initial release.