# Upgrade to version 2

## Elixir version

You need to use Elixir version 1.5 or above.

## Changes

### User context (Accounts) module -> session module

In version 1, you needed to define the functions `get/1` and `get_by/1`.
In version 2, you only need to define a `get_by/1` function.

The following is an example `get_by/1` function if you are using
Phauxth.Authenticate or Phauxth.AuthenticateToken:

```elixir
def get_by(%{"session_id" => session_id}) do
  Repo.get_by(User, session_id: session_id)
end
```

TALK ABOUT CONFIGURING session_module

### Session and token authentication

* Phauxth.Authenticate does not check the session expiry value
  * the session expiry value can be checked in the `get_by/1` function in the user context
* Phauxth.Authenticate for tokens (Phauxth.Authenticate, method: :token)
is now Phauxth.AuthenticateToken
  * there is no token implementation - there is a behaviour instead

### Login

* Phauxth.Login and Phauxth.Confirm.Login have been removed
  * the Phauxth installer and example project contain examples
  of how to replace this functionality

### Password resetting

* Phauxth.Confirm.verify with the `:pass_reset mode` has been renamed to Phauxth.Confirm.PassReset.verify

