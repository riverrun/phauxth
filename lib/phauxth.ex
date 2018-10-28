defmodule Phauxth do
  @moduledoc """
  Authentication library for Phoenix, and other Plug-based, web applications.

  Phauxth is designed to be secure, extensible and well-documented.

  Phauxth offers two types of functions: Plugs, which are called with `plug`,
  and `verify/2` functions.

  ## Plugs

  Plugs take a conn (connection) struct and opts as arguments and return
  a conn struct.

  ### Authenticate

  `Phauxth.Authenticate` checks to see if there is a session_id
  in the current session and sets the current_user value accordingly.

  ### AuthenticateToken

  `Phauxth.AuthenticateToken` checks to see if there is an authorization token
  in the headers, verifies it, and sets the current_user value accordingly.

  ### Remember

  `Phauxth.Remember` checks to see if there is a valid remember_me cookie.
  If there is one, it verifies the cookie and, if the verification is successful,
  adds the user to the session.

  ## Phauxth verify/2

  The `verify/2` functions take a map (usually Phoenix params) and opts
  (an empty list by default) and return `{:ok, user}` or `{:error, message}`.

  ### Login

  `Phauxth.Login.verify` is used for user login.

  ### User confirmation

  `Phauxth.Confirm.verify` is used for email confirmation.

  ### Password resetting

  `Phauxth.Confirm.PassReset.verify` is used for password resetting.

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
  underlying database. This value needs to be set in the config.
  See the documentation for `Phauxth.Config.user_context` for details.

  In addition, the `user_context` module needs to have a `get_by(attrs)`
  function defined (see the examples below).

      @spec get_by(map) :: User.t() | nil
      def get_by(%{"session_id" => session_id}) do
        with %Session{user_id: user_id} <- Sessions.get_session(session_id),
        do: get_user(user_id)
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

  In the default implementations - Confirm.Base and Login.Base, this
  function calls the `authenticate` function with the user params and
  pipes the output to the `report` function.
  """
  @callback verify(map, keyword) :: ok_or_error

  @doc """
  Authenticates the user based on the user params.

  After performing the relevant checks, this function also gets the
  user data (if available).
  """
  @callback authenticate(map, keyword) :: ok_or_error

  @doc """
  Logs the result of the verification and returns `{:ok, user}` or
  `{:error, message}`.
  """
  @callback report(ok_or_error, keyword) :: ok_or_error
end
