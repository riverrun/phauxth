defmodule Phauxth.Confirm.Login do
  @moduledoc """
  A custom Login function which also checks to see if the user's
  account has been confirmed yet.
  """

  use Phauxth.Login.Base

  def check_pass(nil, _, crypto, opts) do
    crypto.no_user_verify(opts)
    {:error, "invalid user-identifier"}
  end
  def check_pass(%{confirmed_at: nil}, _, _, _),
    do: {:error, "account unconfirmed"}
  def check_pass(%{password_hash: hash} = user, password, crypto, opts) do
    crypto.verify_hash(hash, password, opts) and
    {:ok, user} || {:error, "invalid password"}
  end
end
