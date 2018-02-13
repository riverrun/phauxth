defmodule Phauxth do
  @moduledoc """
  Authentication library for Phoenix, and other Plug-based, web applications.

  Phauxth is designed to be secure, extensible and well-documented.

  Phauxth offers two types of functions: Plugs, which are called with plug,
  and `verify/3` functions.

  ## Plugs

  Plugs take a conn (connection) struct and opts as arguments and return
  a conn struct.

  ### Authenticate

  `Phauxth.Authenticate` checks to see if there is a valid cookie or token
  for the user and sets the current_user value accordingly.

  This is usually added to the pipeline you want to authenticate in the
  router.ex file, as in the following example.

      pipeline :browser do
        plug Phauxth.Authenticate
      end

  To authenticate using api tokens, you need to add the `method: :token`
  option.

      plug Phauxth.Authenticate, method: :token

  ### Remember

  This Plug provides a check for a remember_me cookie.

      pipeline :browser do
        plug Phauxth.Authenticate
        plug Phauxth.Remember
      end

  This needs to be called after `plug Phauxth.Authenticate`.

  ## Phauxth verify/3

  The `verify/3` function takes a map (usually Phoenix params), a context
  module (usually MyApp.Accounts) and opts (an empty list by default)
  and returns `{:ok, user}` or `{:error, message}`.

  ### User confirmation

  `Phauxth.Confirm.verify` is used for user confirmation, using email
  or phone.

  The function below is an example of how you would call verify to
  confirm a user's account.

      def new(conn, params) do
        case Phauxth.Confirm.verify(params, MyApp.Accounts) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            message = "Your account has been confirmed"
            Message.confirm_success(user.email)
            handle_success(conn, message, session_path(conn, :new))
          {:error, message} ->
            handle_error(conn, message, session_path(conn, :new))
        end
      end

  Note that the verify function does not update the database or send
  an email to the user. Those need to be handled in your app.

  ### Password resetting

  `Phauxth.Confirm.PassReset.verify` is used for password resetting, as
  in the example below:

      Phauxth.Confirm.PassReset.verify(params, MyApp.Accounts)

  This function just verifies the confirmation key. It does not reset
  the password or send an email to the user.

  ## Phauxth with a new Phoenix project

  The easiest way to get started is to use the phauxth_new installer.
  First, download and install it:

      mix archive.install https://github.com/riverrun/phauxth_installer/raw/master/archives/phauxth_new.ez

  Then run the `mix phauxth.new` command in the main directory of the
  Phoenix app. The following options are available:

    * `--api` - create files for an api
    * `--confirm` - add files for email confirmation
    * `--remember` - add `remember_me` functionality
    * `--backups` - create backup files, with `.bak` extension, before writing new files

  Phauxth uses the user context module (normally MyApp.Accounts) to communicate
  with the underlying database. This module needs to have the `get(id)` and
  `get_by(attrs)` functions defined (see the examples below).

      def get(id), do: Repo.get(User, id)

      def get_by(%{"email" => email}) do
        Repo.get_by(User, email: email)
      end

  ## Customizing Phauxth

  See the documentation for Phauxth.Authenticate.Base and Phauxth.Confirm.Base
  for more information on extending these modules.

  You can find more information at the
  [Phauxth wiki](https://github.com/riverrun/phauxth/wiki).

  """
end
