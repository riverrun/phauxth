defmodule Phauxth.Confirm.Login do
  @moduledoc """
  A custom Login function which also checks to see if the user's
  account has been confirmed yet.
  """

  use Phauxth.Login.Base

  def check_pass(nil, _) do
    Bcrypt.dummy_checkpw
    {:error, "invalid user-identifier"}
  end
  def check_pass(%{confirmed_at: nil}, _),
    do: {:error, "account unconfirmed", "You have to confirm your account"}
  def check_pass(%{password_hash: hash} = user, password) do
    Bcrypt.checkpw(password, hash) and
    {:ok, user} || {:error, "invalid password"}
  end
end
