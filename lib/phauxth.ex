defmodule Phauxth do
  @moduledoc """
  Authentication library for Phoenix, and other Plug-based, web applications.

  Phauxth is designed to be secure, extensible and well-documented.

  Phauxth offers two types of functions: Plugs, which are called with plug,
  and `verify/2` functions.

  ## Plugs

  Plugs take a conn (connection) struct and opts as arguments and return
  a conn struct.

  ### Authenticate

  `Phauxth.Authenticate` checks to see if there is a session_id
  in the current session and sets the current_user value accordingly.

  This is usually added to the pipeline you want to authenticate in the
  router.ex file, as in the following example.

      pipeline :browser do
        plug Phauxth.Authenticate
      end

  ### AuthenticateToken

  `Phauxth.AuthenticateToken` checks to see if there is an authorization token
  in the headers, verifies it, and sets the current_user value accordingly.

      plug Phauxth.AuthenticateToken

  ### Remember

  This Plug provides a check for a remember_me cookie.

      pipeline :browser do
        plug Phauxth.Authenticate
        plug Phauxth.Remember
      end

  This needs to be called after `plug Phauxth.Authenticate`.

  ## Phauxth verify/2

  The `verify/2` function takes a map (usually Phoenix params) and opts
  (an empty list by default) and returns `{:ok, user}` or `{:error, message}`.

  ### Login

  ### User confirmation

  `Phauxth.Confirm.verify` is used for email confirmation.

  The function below is an example of how you would call verify to
  confirm a user's account.

      def new(conn, params) do
        case Phauxth.Confirm.verify(params) do
          {:ok, user} ->
            Users.confirm_user(user)
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

      Phauxth.Confirm.PassReset.verify(params)

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

  Phauxth uses the `user_context` module to communicate with the
  underlying database. This value can be set in the config - see the documentation
  for `Phauxth.Config.user_context` for details.

  The `user_context` module needs to have a `get_by(attrs)` function
  defined (see the examples below).

      def get_by(%{"session_id" => session_id}) do
        Repo.get(Session, session_id)
      end

      def get_by(%{"user_id" => user_id}) do
        Repo.get(User, user_id)
      end

      def get_by(%{"email" => email}) do
        Repo.get_by(User, email: email)
      end

  ## Customizing Phauxth

  See the documentation for Phauxth.Authenticate.Base, Phauxth.Authenticate.Token
  and Phauxth.Confirm.Base for more information on extending these modules.

  You can also find more information at the
  [Phauxth wiki](https://github.com/riverrun/phauxth/wiki).
  """

  @type ok_or_error :: {:ok, map} | {:error, String.t() | atom}

  @doc """
  Verifies the user based on the user params.
  """
  @callback verify(map, keyword) :: ok_or_error

  @doc """
  Authenticates the user based on the user params.
  """
  @callback authenticate(map, keyword) :: ok_or_error

  @doc """
  Logs the result of the verification and returns `{:ok, user}` or
  `{:error, message}`.
  """
  @callback report(ok_or_error, keyword) :: ok_or_error
end
