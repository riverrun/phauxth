# Phauxth

[![Hex.pm Version](http://img.shields.io/hexpm/v/phauxth.svg)](https://hex.pm/packages/phauxth)
[![Join the chat at https://gitter.im/phauxth_elixir/Lobby](https://badges.gitter.im/phauxth_elixir/Lobby.svg)](https://gitter.im/phauxth_elixir/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Authentication library for Phoenix, and other Plug-based, web applications.

## Version 2.0.0-rc and 1.2

The master branch points to version 2.0.0-rc, which is being developed
with phoenix 1.4 in mind.

The v1.2 branch has the version 1.2, which is the stable version.

## Overview

Phauxth is designed with Phoenix >1.3 in mind, but it can also be used with
older versions of Phoenix and any other Plug-based application. It is
designed to be secure, extensible and well-documented.

For a general overview of some of the goals of Phauxth and its basic usage,
see [this post](https://riverrun.github.io/projects/phauxth/2017/09/25/phauxth.html).

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

## Phauxth examples

* [A basic example](https://github.com/riverrun/phauxth-example) of using
Phauxth with email confirmation.
* [An example api](https://github.com/riverrun/phoenix-todoapp) using Phauxth.

### License

BSD
