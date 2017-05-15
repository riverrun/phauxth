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

  import Ecto.{Changeset, Query}
  import Phauxth.Login.Base
  alias Comeonin.Otp
  alias Phauxth.Config

  def verify(params, opts \\ [])
  def verify(%{"id" => id, "hotp" => hotp}, opts) do
    {:ok, result} = Config.repo.transaction(fn ->
      get_user_with_lock(Config.user_mod, id)
      |> check_hotp(hotp, opts)
      |> update_otp
    end)
    log(result, id, "successful one-time password login")
  end
  def verify(%{"id" => id, "totp" => totp}, opts) do
    Config.repo.get(Config.user_mod, id)
    |> check_totp(totp, opts)
    |> update_otp
    |> log(id, "successful one-time password login")
  end

  def check_hotp(user, hotp, opts) do
    {user, Otp.check_hotp(hotp, user.otp_secret, [last: user.otp_last] ++ opts)}
  end

  def check_totp(user, totp, opts) do
    {user, Otp.check_totp(totp, user.otp_secret, opts)}
  end

  def get_user_with_lock(user_model, id) do
    from(u in user_model, where: u.id == ^id, lock: "FOR UPDATE")
    |> Config.repo.one!
  end

  def update_otp({_, false}), do: {:error, "invalid one-time password"}
  def update_otp({%{otp_last: otp_last} = user, last}) when last > otp_last do
    change(user, %{otp_last: last}) |> Config.repo.update
  end
  def update_otp(_), do: {:error, "invalid user-identifier"}
end
