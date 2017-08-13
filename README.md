# Phauxth

[![Hex.pm Version](http://img.shields.io/hexpm/v/phauxth.svg)](https://hex.pm/packages/phauxth)
[![Join the chat at https://gitter.im/phauxth_elixir/Lobby](https://badges.gitter.im/phauxth_elixir/Lobby.svg)](https://gitter.im/phauxth_elixir/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Authentication framework for Phoenix, and other Plug-based, web applications.

Phauxth is designed with Phoenix 1.3 in mind, but it can also be used with
older versions of Phoenix and any other Plug-based application.

## Configuring Phauxth

Phauxth uses the user context module (normally MyApp.Accounts) to communicate
with the underlying database. This module needs to have the `get(id)` and
`get_by(attrs)` functions defined (see the examples below).

```elixir
def get(id), do: Repo.get(User, id)

def get_by(%{"email" => email}) do
  Repo.get_by(User, email: email)
end
```

In addition, if you are using tokens, for an api or for user confirmation,
you need to add `token_salt` to the Phauxth config. You can generate a
suitably secure random salt by running the `Phauxth.Config.gen_token_salt`
command.

## Getting started with Phauxth and Phoenix

### Create new Phoenix project

Run the following commands (replace alibaba with the name of your project):

    mix phx.new alibaba
    cd alibaba

To create an api, change the `mix phx.new` command to:

    mix phx.new alibaba --no-html --no-brunch

### Run the Phauxth installer

N.B. if you are not using Erlang 20, you might have to build the installer
yourself. You can find the instructions in the README in the installer/new
directory.

Download and install the [phauxth_new installer](https://github.com/riverrun/phauxth/raw/master/installer/archives/phauxth_new.ez).

    mix archive.install https://github.com/riverrun/phauxth/raw/master/installer/archives/phauxth_new.ez

For a basic setup, run the following command:

    mix phauxth.new

If you want to add email / phone confirmation and password resetting, add the `--confirm` option:

    mix phauxth.new --confirm

If you want to create authentication files for an api, use the `--api` option:

    mix phauxth.new --api

And for api with user confirmation:

    mix phauxth.new --api --confirm

### Add phauxth to deps

1. Make sure you are using Elixir 1.4 or above.

2. Add phauxth and the password hashing algorithm you want to use
(argon2_elixir, bcrypt_elixir or pbkdf2_elixir) to your `mix.exs` dependencies.

```elixir
defp deps do
  [
    {:phauxth, "~> 0.17"},
    {:bcrypt_elixir, "~> 0.12"},
  ]
end
```

3. Run `mix deps.get`.

4. Add the `get(id)` and `get_by(attrs)` functions to your user Accounts module.

5. If you are using tokens, add the token_salt and endpoint values to the config.

See the [wiki](https://github.com/riverrun/phauxth/wiki) for more
information about Phauxth.

### License

BSD
