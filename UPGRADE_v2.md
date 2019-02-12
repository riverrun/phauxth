# Updating to Phauxth 2.1.0

## Elixir version

You need to use Elixir version 1.7 or above.

## Configuration

In most cases, you will need to set the following values:

* user_context
* crypto_module - needed for Phauxth.Login
  * the recommended value is Argon2
* token_module - needed for Phauxth.AuthenticateToken, Phauxth.Confirm and Phauxth.Remember
  * you need to write this yourself - see the Phauxth.Token module for more information

## Phauxth.Authenticate

### with sessions

This no longer uses the `get/1` function in the user_context module.
Instead, Phauxth.Authenticate uses the `get_by(%{"session_id" => session_id})`
function.

In addition, Phauxth.Authenticate does not check if the session has
expired - you need to do that in the `get_by/1` function, as in the
example below:

```
def get_by(%{"session_id" => session_id}) do
  with %Session{user_id: user_id} <- Sessions.get_session(session_id),
       do: get_user(user_id)
end
```

with `Sessions.get_session/1` something like:

```
def get_session(id) do
  now = DateTime.utc_now()
  Repo.get(from(s in Session, where: s.expires_at > ^now), id)
end
```

### with tokens

Change `plug Phauxth.Authenticate, method: :token` to `plug Phauxth.AuthenticateToken`

## Phauxth.Remember

You need to define a `create_session/1` function and add this function
to the opts when calling Phauxth.Remember.

The `create_session/1` function takes the conn as input and should return
`{:ok, session}` or `{:error, message}`, as in the example below:

```
def create_session(%Plug.Conn{assigns: %{current_user: %{id: user_id}}}) do
  Sessions.create_session(%{user_id: user_id})
end
```

with `Sessions.create_session/1` adding the session data to the database.

## Phauxth.Login.verify and Phauxth.Confirm.verify

Change `Phauxth.Login.verify(params, MyApp.Users)` or `Phauxth.Confirm.verify(params, MyApp.Users)` to:

`Phauxth.Login.verify(params)` or `Phauxth.Confirm.verify(params)` (with the user_context set in the config)

or you can set the user_context as an option, as in the following example:

`Phauxth.Login.verify(params, user_context: MyApp.OtherUsers)`

### Login

`Phauxth.Confirm.Login` and `Phauxth.Login.add_session` have been removed.

`Phauxth.Confirm.Login` can be replaced by adding a module like the following
to your app:

```
defmodule MyAppWeb.Auth.Login do
  use Phauxth.Login.Base

  alias MyApp.Accounts

  @impl true
  def authenticate(%{"password" => password} = params, _, opts) do
    case Accounts.get_by(params) do
      nil -> {:error, "no user found"}
      %{confirmed_at: nil} -> {:error, "account unconfirmed"}
      user -> Argon2.check_pass(user, password, opts)
    end
  end
end
```

and `Phauxth.Login.add_session` can be replaced by adding the following
function to the session controller:

```
defp add_session(conn, user, params) do
  {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

  conn
  |> delete_session(:request_path)
  |> put_session(:phauxth_session_id, session_id)
  |> configure_session(renew: true)
end
```

### Password resetting

`Phauxth.Confirm.verify` with the `:pass_reset mode` has been renamed to `Phauxth.Confirm.PassReset.verify`.

## Token authentication

The Phauxth.Token module now defines a behaviour which you can use to
define your own token implementation.

If you are using tokens, you will need to add a module that uses the
Phauxth.Token behaviour to your app - and set this module as the `token_module`
in the config.

Below is an example implementation using Phoenix.Token (the token_salt value
should be a random string - you can use `Phauxth.Config.gen_token_salt` to
generate it):

```
defmodule MyAppWeb.Auth.Token do
  @behaviour Phauxth.Token

  alias Phoenix.Token
  alias MyAppWeb.Endpoint

  @token_salt "JaKgaBf2"

  @impl true
  def sign(data, opts \\ []) do
    Token.sign(Endpoint, @token_salt, data, opts)
  end

  @impl true
  def verify(token, opts \\ []) do
    Token.verify(Endpoint, @token_salt, token, opts)
  end
end
```

## Customizing Phauxth

This section is only relevant if you were customizing any of the Phauxth plugs or
verify functions.

* the Phauxth behaviour (used by Confirm.Base and Login.Base) now has three callbacks: verify/2, authenticate/3 and report/2
* Phauxth.Authenticate.Base `get_user` callback is now `authenticate`, and it returns {:ok, user} or {:error, message}

