defmodule Phauxth.Otp.Base do
  @moduledoc """
  """

  import Ecto.{Changeset, Query}
  alias Comeonin.Otp
  alias Phauxth.Config

  @doc false
  defmacro __using__(_) do
    quote do
      use Phauxth.Login.Base
      import unquote(__MODULE__)

      def verify(conn, %{"user" => %{"id" => id, "hotp" => hotp}}, opts \\ []) do
        {:ok, result} = Config.repo.transaction(fn ->
          get_user_with_lock(Config.user_mod, id)
          |> check_hotp(hotp, opts)
          |> update_otp
        end)
        log(result, conn, id, "successful one-time password login")
      end
      def verify(conn, %{"user" => %{"id" => id, "totp" => totp}}, opts \\ []) do
        Config.repo.get(Config.user_mod, id)
        |> check_totp(totp, opts)
        |> update_otp
        |> log(conn, id, "successful one-time password login")
      end

      defoverridable [verify: 3]
    end
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
