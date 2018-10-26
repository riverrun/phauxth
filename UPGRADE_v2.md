# Upgrade to version 2

## Elixir version

You need to use Elixir version 1.7 or above.

## Changes

### User context module

In version 1, you needed to define the functions `get/1` and `get_by/1`.
Now, in version 2, you only need to define a `get_by/1` function.

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
Phauxth.Confirm.verify(params, MyApp.Users)
```

is now:

```elixir
Phauxth.Confirm.verify(params) # with user_context set in the config
```

or:

```elixir
Phauxth.Confirm.verify(params, user_context: MyApp.Users)
```

### Session and token authentication

* Phauxth.Token module now defines a behaviour which you can use to define your own token implementation
  * the Phauxth.PhxToken module provides an example of using this behaviour with Phoenix tokens
* Phauxth.Authenticate for tokens (Phauxth.Authenticate, method: :token)
is now Phauxth.AuthenticateToken
* Phauxth.Authenticate does not check the session expiry value
  * the session expiry value can be checked in the `get_by/1` function in the user context

### Login

* Phauxth.Login and Phauxth.Confirm.Login have been removed
  * the Phauxth installer and example project contain examples
  of how to replace this functionality

### Password resetting

* Phauxth.Confirm.verify with the `:pass_reset mode` has been renamed to Phauxth.Confirm.PassReset.verify

### Customizing Phauxth

This section is only relevant if you were customizing any of the Phauxth plugs or
verify functions.

* the `init` function for Authenticate.Base now returns a map instead of a tuple
* the `get_user` function in Authenticate.Base now takes a conn and map as input
* the `get_user` function in Confirm.Base now takes a token and map as input

