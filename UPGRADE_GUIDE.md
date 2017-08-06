# Upgrading to version 0.15 of Phauxth

* In Phauxth.Confirm and Phauxth.Confirm.PassReset, change the verify function
from:

```elixir
verify(params, MyApp.Accounts)
```

to:

```elixir
verify(params, MyApp.Accounts, {conn, 20})
```

    * conn can be replaced by the name of the endpoint in your app
    * 20 refers to the maximum age of the token, in minutes
* Remove the `confirmation_token`, `confirmation_sent_at` and `reset_token`
database entries in the user.ex and user migration files
    * these are no longer needed as tokens (based on Phoenix.Token) are now being used
* Change `Ecto.DateTime` to `:utc_datetime` in the user.ex file

## Additional changes

Phauxth now uses a customized version of Phoenix.Token.
This removes the dependency on Phoenix, and so it should be
more straightforward to use it with any Plug-based application.

# Upgrading to Phauxth from Openmaize

The rest of this document shows the changes you need to make when
upgrading from Openmaize to Phauxth. For more information, see
each module's documentation.

## Changes

### Interaction with the database

Instead of setting a default repo and user schema, Phauxth now uses
the user context module (`Accounts` by default), which is new in Phoenix
1.3. This module needs to have the following two functions:

* get(id) - get the user by id
* get_by(params) - get the user by using the params output by the Phoenix function

The default context (:user_context) is set in the `opts` argument for the Plugs,
and it is the second argument in the verify/3 functions.

The default is MyApp.Accounts.

### Plugs

#### Authenticate

Phauxth.Authenticate adds token (api) authentication, using Phoenix token. It
still supports authentication using Plug sessions.

#### Remember

The underlying implementation now uses Phoenix token in a cookie. When upgrading,
the old Openmaize.Remember cookie will not be recognised, forcing the user to
login again.

### Login, Confirm and Confirm.PassReset

The Login, Confirm (ConfirmEmail) and Confirm.PassReset (ResetPassword)
Plugs have been removed, and replaced with verify/3 functions, which are
called within the controller function.

For all of these functions, there is no longer any need to set the
user-identifier (email, username, etc.).

#### Login

Instead of calling `plug Openmaize.Login when action in [:create]` in
the session controller, the Login.verify function is moved to within
the create function, as in the example below.

    ```elixir
      def create(conn, %{"session" => session_params}) do
        case Phauxth.Login.verify(session_params, MyApp.Accounts) do
          {:ok, user} -> handle_successful_login
          {:error, _message} -> handle_error
        end
      end
    ```

You can also now decide to use a different password hashing library,
which is set in the `opts` for Login.verify (the default is Comeonin.Bcrypt):

    Phauxth.Login.verify(session_params, MyApp.Accounts, crypto: Comeonin.Argon2)

Phauxth is tested with Comeonin and the three algorithms it now supports:
`argon2_elixir`, `bcrypt_elixir` and `pbkdf2_elixir`. These are optional
dependencies, and so you need to add one of them to the `deps` section
in your mix.exs file.

#### Email confirmation and password resetting

Openmaize.ConfirmEmail is now Phauxth.Confirm.verify and
Openmaize.ResetPassword is now Phauxth.Confirm.PassReset.verify.

With Openmaize, the database was updated and an email sent to the user within
the Plug. With Phauxth, the two functions to update the database and send the email are
moved outside, and so developers need to call these functions themselves
in the confirm_controller, or password_reset_controller. You can see
examples of this in the installer.

### Helper functions

Several database helper functions have been removed. These (adding the password hash,
confirmation token, etc.) have been moved to the accounts.ex file in the installer.

