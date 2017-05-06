# Upgrading to Phauxth from Openmaize

## Changes

### Config

The default repo and user model (user_mod) need to be set in the config.

Add the following to the config/config.exs file:

    ```elixir
    config, :phauxth,
      repo: MyApp.Repo,
      user_mod: MyApp.Accounts.User
    ```

### Plugs

#### Authenticate

Phauxth.Authenticate adds token (api) authentication, using Phoenix token. It
still supports authentication using Plug sessions.

#### Remember

The underlying implementation now uses Phoenix token in a cookie. When upgrading,
the old Openmaize.Remember cookie will not be recognised, forcing the user to
login again.

#### Login

No changes.

#### One time password

Openmaize.OnetimePass is now Phauxth.Otp. The options are the same.

#### Email confirmation and password resetting

Openmaize.ConfirmEmail is now Phauxth.Confirm and
Openmaize.ResetPassword is now Phauxth.Confirm.PassReset.

There is now an option to change the user-identifier -- to phone, for example, from email.

With Openmaize, the database was updated and an email sent to the user within
the Plug. With Phauxth, these two functions are moved outside, and so developers
need to call these functions themselves in the confirm_controller, or
password_reset_controller. You can see examples of this in the installer.

### Helper functions

Several database helper functions have been removed. These (adding the password hash,
confirmation token, etc.) have been moved to the accounts.ex file in the installer.



