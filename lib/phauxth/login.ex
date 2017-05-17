defmodule Phauxth.Login do
  @moduledoc """
  Module to handle login.

  `Phauxth.Login` checks the user's password, and returns a `phauxth_user`
  message (the user model) if login is successful or a `phauxth_error`
  message if there is an error.

  After this function has been called, you need to either add the user
  to the session, by running `put_session(conn, :user_id, id)`, or send
  an API token to the user.

  If you are using two-factor authentication, you need to first check
  the user model for `otp_required: true` and, if necessary, redirect
  the user to the one-time password input page.

  ## Options

  There is one option:

    * identifier - the name which is used to identify the user (in the database)
      * this should be an atom, and the default is `:email`

  """

  use Phauxth.Login.Base

end
