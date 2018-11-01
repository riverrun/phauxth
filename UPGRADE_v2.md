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

Previously, the second argument to the verify function was the `user_context`
module. Now, this is set in the config.

```elixir
Phauxth.Confirm.verify(params, MyApp.Users)
Phauxth.Login.verify(params, MyApp.Users)
```

is now:

```elixir
Phauxth.Confirm.verify(params) # with user_context set in the config
Phauxth.Login.verify(params)
```

### Session authentication

* Phauxth.Authenticate does not check the session expiry value
  * the session expiry value can be checked in the `get_by/1` function in the user context

### Token authentication

* Phauxth.Token module now defines a behaviour which you can use to define your own token implementation
* Phauxth.Authenticate for tokens (Phauxth.Authenticate, method: :token) is now Phauxth.AuthenticateToken

### Login

* Phauxth.Confirm.Login has been removed
* the `crypto_module` for Phauxth.Login is now set in the config

### Password resetting

* Phauxth.Confirm.verify with the `:pass_reset mode` has been renamed to Phauxth.Confirm.PassReset.verify

### Remember me

* to use Phauxth.Remember, you need to define a `create_session(user)` function in the user_context module
  * this function should return `{:ok, session}` or `{:error, message}`

### Customizing Phauxth

This section is only relevant if you were customizing any of the Phauxth plugs or
verify functions.

* the Phauxth behaviour (used by Confirm.Base and Login.Base) now has three callbacks: verify/2, authenticate/2 and report/2
* Phauxth.Authenticate.Base `get_user` callback is now `authenticate`, and it returns {:ok, user} or {:error, message}

