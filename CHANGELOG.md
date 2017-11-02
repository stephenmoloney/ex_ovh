# Changelog


## v0.4.0

- Bump dependencies and remove many deprecations for elixir 1.5+

## v0.3.6

[changes]
- Remove `mod: []` as this caused some release warnings. No Module Supervisor
is started by default.
- bump version of `:httpipe_adapters_hackney`

## v0.3.5

[changes]
- Added `:floki` to list of applications to remove
warnings when making a release.

## v0.3.4

[bug fix]
- Added `:poison` to list of applications to remove
warnings when making a release.

## v0.3.3

[bug fix]
- Fix error `function :hackney.execute_request/5 is undefined or private` when
running `mix ovh` task by setting the adapter correctly


## v0.3.2

[security fix]
- Remove dependency on `Og`. A potential security issue existed for `og` versions below `1.0.0`. See
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107).
As `Og` was removed anyways as a dependency in `v0.3.2` of `ex_ovh`, this issue is resolved.

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
due to the inclusion of older releases of the dependency `Og` Use versions `0.3.2` only of `ex_ovh`***

- Initial release.