defmodule Phauxth.Login do
  @moduledoc """
  Module to handle login.

  `Phauxth.Login.verify/2` checks the user's password, and returns
  {:ok, user} if login is successful or {:error, message} if there
  is an error.

  If login is successful, you need to either add the user to the
  session, by running `put_session(conn, :user_id, id)`, or send
  an API token to the user.

  If you are using two-factor authentication, you need to first check
  the user schema for `otp_required: true` and, if necessary, redirect
  the user to the one-time password input page.

  ## Options

  There is one option:

    * identifier - the name which is used to identify the user (in the database)
      * this should be an atom, and the default is `:email`

  """

  use Phauxth.Login.Base

end
