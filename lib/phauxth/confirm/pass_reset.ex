defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Confirm a user and reset the password.

  ## Options

  There are two options:

    * identifier - how user is identified in the confirmation request
      * this should be an atom, and the default is :email
    * key_validity - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)

  ## Examples

  """

  use Phauxth.Confirm.Base, ok_log: "password reset"

  def check_key(nil, _, _), do: {:error, "invalid credentials"}
  def check_key(user, key, valid_secs) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_compare(user.reset_token, key) and {:ok, user}
  end
end
