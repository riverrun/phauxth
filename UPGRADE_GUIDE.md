# Upgrading to Phauxth from Openmaize

This document shows the changes you need to make when upgrading from Openmaize
to Phauxth. For more information, see the each module's documentation.

## Changes

### Interaction with the database

The repo and user schema is set in the `opts` argument for the Plugs
and verify/2 functions.

The default repo is MyApp.Repo and the default user_schema is MyApp.Accounts.User

### Plugs

#### Authenticate

Phauxth.Authenticate adds token (api) authentication, using Phoenix token. It
still supports authentication using Plug sessions.

#### Remember

The underlying implementation now uses Phoenix token in a cookie. When upgrading,
the old Openmaize.Remember cookie will not be recognised, forcing the user to
login again.

### Login, Otp, Confirm and Confirm.PassReset

The Login, Otp, Confirm (ConfirmEmail) and Confirm.PassReset (ResetPassword)
Plugs have been removed, and replaced with verify/2 functions, which are
called within the controller function.

#### Login

Instead of calling `plug Openmaize.Login when action in [:create]` in
the session controller, the Login.verify function is moved to within
the create function, as in the example below.

    ```elixir
      def create(conn, %{"session" => session_params}) do
        case Phauxth.Login.verify(session_params) do
          {:ok, user} -> handle_successful_login
          {:error, _message} -> handle_error
        end
      end
    ```

#### One time password

The Openmaize.OnetimePass is now Phauxth.Otp.verify.

It should be called the same way as the Login.verify in the example
above. The options are the same.

#### Email confirmation and password resetting

Openmaize.ConfirmEmail is now Phauxth.Confirm.verify and
Openmaize.ResetPassword is now Phauxth.Confirm.PassReset.verify.

There is now an option to change the user-identifier -- to phone, for example, from email.

With Openmaize, the database was updated and an email sent to the user within
the Plug. With Phauxth, the two functions to update the database and send the email are
moved outside, and so developers need to call these functions themselves
in the confirm_controller, or password_reset_controller. You can see
examples of this in the installer.

### Helper functions

Several database helper functions have been removed. These (adding the password hash,
confirmation token, etc.) have been moved to the accounts.ex file in the installer.

