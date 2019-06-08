# Phauxth

[![Hex.pm Version](http://img.shields.io/hexpm/v/phauxth.svg)](https://hex.pm/packages/phauxth)
[![Build Status](https://travis-ci.org/riverrun/phauxth.svg?branch=master)](https://travis-ci.org/riverrun/phauxth)

Phauxth is an authentication library for Phoenix, and other Plug-based,
web applications. It is designed to be secure, extensible, easy to use
and well-documented.

For a general overview of some of the goals of Phauxth and its basic usage,
see [this post](https://riverrun.github.io/projects/phauxth/2017/09/25/phauxth.html).

## Upgrading from version 2.0 to 2.1

In version 2.1 and above, you need to remove all the references to Comeonin.
Make the following changes in your app (if necessary, replacing Argon2
with the hashing module you are using):

* in the user context module, change `Comeonin.Argon2.add_hash` to `Argon2.add_hash`
* if you are using a custom login module, remove `alias Comeonin.Argon2`
* in the Phauxth config, replace `Comeonin.Argon2` with `Argon2`

For more details, see the [upgrade guide](https://github.com/riverrun/phauxth/blob/master/UPGRADE_v2.1.md).

## Getting started

[This guide](https://github.com/riverrun/phauxth/wiki/Getting-started)
shows how you can set up a new Phoenix project with Phauxth.

## Authentication and authorization

The core Phauxth library handles authentication, verifying who the
user is.

For information about authorization, or access control, see the
[Authorization](https://github.com/riverrun/phauxth/wiki/Authorization) page
in the wiki.

If you have set up your app using the [Phauxth installer](https://github.com/riverrun/phauxth_installer),
the `authorize.ex` file in the controllers directory provides examples
of functions you can use to authorize users' access to resources.

## Example apps using Phauxth

* [A basic example](https://github.com/riverrun/phauxth-example) of using
Phauxth with email confirmation.
* [An example api](https://github.com/riverrun/phoenix-todoapp) using Phauxth.

## Contributing

There are many ways you can contribute to the development of Phauxth, including:

* reporting issues
* improving documentation
* sharing your experiences with others
* [making a financial contribution](#donations)

## Donations

First of all, I would like to emphasize that this software is offered
free of charge. However, if you find it useful, and you would like to
buy me a cup of coffee, you can do so at [paypal](https://www.paypal.me/alovedalongthe).

### Documentation

http://hexdocs.pm/phauxth

### License

BSD
