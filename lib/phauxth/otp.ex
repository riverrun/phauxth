defmodule Phauxth.Otp do
  @moduledoc """
  Module to handle one-time passwords, usually for use in two factor
  authentication.

  `Phauxth.Otp.verify/3` checks the one-time password, and returns
  {:ok, user} if the one-time password is correct or {:error, message}
  if there is an error.

  After this function has been called, you need to either add the user
  to the session, by running `put_session(conn, :user_id, id)`, or send
  an API token to the user.

  ## Options

  There are the following options for the one-time passwords:

    * HMAC-based one-time passwords
      * token_length - the length of the one-time password
        * the default is 6
      * last - the count when the one-time password was last used
        * this count needs to be stored server-side
      * window - the number of future attempts allowed
        * the default is 3
    * Time-based one-time passwords
      * token_length - the length of the one-time password
        * the default is 6
      * interval_length - the length of each timed interval
        * the default is 30 (seconds)
      * window - the number of attempts, before and after the current one, allowed
        * the default is 1 (1 interval before and 1 interval after)

  See the documentation for the Comeonin.Otp module for more details
  about generating and verifying one-time passwords.

  ## Examples

  """

  use Phauxth.Otp.Base

end
