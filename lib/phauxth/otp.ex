defmodule Phauxth.Otp do
  @moduledoc """
  Module to handle one-time passwords for use in two factor authentication.

  `Phauxth.Otp` checks the one-time password, and returns an
  `phauxth_user` message (the user model) if the one-time password is
  correct or an `phauxth_error` message if there is an error.

  After this function has been called, you need to add the user to the
  session, by running `put_session(conn, :user_id, id)`, or send an API
  token to the user.

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

  Add the following line to your controller to call Otp with the
  default values:

      plug Phauxth.Otp when action in [:login_twofa]

  And to set the token length to 8 characters:

      plug Phauxth.Otp, [token_length: 8] when action in [:login_twofa]

  """

  @behaviour Plug

  import Ecto.{Changeset, Query}
  import Phauxth.Login.Base
  alias Comeonin.Otp
  alias Phauxth.Config

  @doc false
  def init(opts), do: opts

  @doc false
  def call(%Plug.Conn{params: %{"user" => %{"id" => id, "hotp" => hotp}}} = conn, opts) do
    {:ok, result} = Config.repo.transaction(fn ->
      get_user_with_lock(Config.user_mod, id)
      |> check_hotp(hotp, opts)
      |> update_otp
    end)
    report(result, conn, id, "successful one-time password login")
  end
  def call(%Plug.Conn{params: %{"user" => %{"id" => id, "totp" => totp}}} = conn, opts) do
    Config.repo.get(Config.user_mod, id)
    |> check_totp(totp, opts)
    |> update_otp
    |> report(conn, id, "successful one-time password login")
  end

  defp check_hotp(user, hotp, opts) do
    {user, Otp.check_hotp(hotp, user.otp_secret, [last: user.otp_last] ++ opts)}
  end

  defp check_totp(user, totp, opts) do
    {user, Otp.check_totp(totp, user.otp_secret, opts)}
  end

  defp get_user_with_lock(user_model, id) do
    from(u in user_model, where: u.id == ^id, lock: "FOR UPDATE")
    |> Config.repo.one!
  end

  defp update_otp({_, false}), do: {:error, "invalid one-time password"}
  defp update_otp({%{otp_last: otp_last} = user, last}) when last > otp_last do
    change(user, %{otp_last: last}) |> Config.repo.update
  end
  defp update_otp(_), do: {:error, "invalid user-identifier"}
end
