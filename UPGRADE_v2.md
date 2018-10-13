# Upgrade to version 2

## Elixir version

You need to use Elixir version 1.7 or above.

## Changes

### User context (Accounts) module -> session module

The `user_context` module, which was used to find user information from
the database, is now the `session_module`, and it can be set in the config,
or overridden in the `opts` (see the section about changes to the `verify`
function for examples).

In addition, in version 1, you needed to define the functions `get/1`
and `get_by/1`. Now, in version 2, you only need to define a `get_by/1`
function.

The following is an example `get_by/1` function if you are using
Phauxth.Authenticate or Phauxth.AuthenticateToken:

```elixir
def get_by(%{"session_id" => session_id}) do
  Repo.get_by(User, session_id: session_id)
end
```

### verify/3 -> verify/2

Previously, the second argument to the verify function was the user_context
module. Now, this is set in the config, or the opts.

```elixir
Phauxth.Confirm.verify(params, MyApp.Accounts)
```

is now:

```elixir
Phauxth.Confirm.verify(params) # with session_module set in the config
```

or:

```elixir
Phauxth.Confirm.verify(params, session_module: MyApp.Sessions)
```

### Session and token authentication

* Phauxth.Authenticate does not check the session expiry value
  * the session expiry value can be checked in the `get_by/1` function in the user context
* Phauxth.Authenticate for tokens (Phauxth.Authenticate, method: :token)
is now Phauxth.AuthenticateToken
  * there is no token implementation
    * the Phauxth.Token module defines a behaviour which you can use to define your own token implementation
      * the Phauxth.PhxToken module provides an example of using this behaviour

### Login

* Phauxth.Login and Phauxth.Confirm.Login have been removed
  * the Phauxth installer and example project contain examples
  of how to replace this functionality

### Password resetting

* Phauxth.Confirm.verify with the `:pass_reset mode` has been renamed to Phauxth.Confirm.PassReset.verify

