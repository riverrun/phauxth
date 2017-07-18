defmodule Phauxth.Login do
  @moduledoc """
  Module to handle login.

  `Phauxth.Login.verify/3` checks the user's password, and returns
  {:ok, user} if login is successful or {:error, message} if there
  is an error.

  If login is successful, you need to either add the user to the
  session, by running `put_session(conn, :user_id, id)`, or send
  an API token to the user.

  If you are using two-factor authentication, you need to first check
  the user schema for `otp_required: true` and, if necessary, redirect
  the user to the one-time password input page.

  ## Options

  There are two options for the verify function:

    * identifier - the name which is used to identify the user (in the database)
      * this should be an atom, and the default is `:email`
    * crypto - the password hashing algorithm to use
      * the default is Comeonin.Bcrypt

  The check_pass function also has options. See the documentation for
  the password hashing module you are using for details.

  ## Examples

  In the example below, Phauxth.Login.verify is called within the create
  function in the session controller.

      def create(conn, %{"session" => params}) do
        case Phauxth.Login.verify(params, MyApp.Accounts) do
          {:ok, user} -> handle_successful_login
          {:error, message} -> handle_error
        end
      end

  """

  use Phauxth.Login.Base

end
