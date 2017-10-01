# Phauxth

[![Hex.pm Version](http://img.shields.io/hexpm/v/phauxth.svg)](https://hex.pm/packages/phauxth)
[![Join the chat at https://gitter.im/phauxth_elixir/Lobby](https://badges.gitter.im/phauxth_elixir/Lobby.svg)](https://gitter.im/phauxth_elixir/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Authentication library for Phoenix, and other Plug-based, web applications.

Phauxth is designed with Phoenix 1.3 in mind, but it can also be used with
older versions of Phoenix and any other Plug-based application.

[This guide](https://github.com/riverrun/phauxth/wiki/Getting-started)
shows how you can set up a new Phoenix project with Phauxth.

## Upgrading from Phauxth 1.1.0 and tokens

Minor changes were made to the token implementation in version 1.1.1.
As a result, when upgrading from 1.1.0 (or earlier) to versions higher
than 1.1.0, the old tokens will no longer be valid, so the end users
need to login again to generate new tokens.

## Phauxth examples

* [A basic example](https://github.com/riverrun/phauxth-example) of using
Phauxth with email confirmation.
* [An example api](https://github.com/riverrun/phoenix-todoapp) using Phauxth.

### License

BSD
