defmodule Phauxth.Confirm.Login do
  @moduledoc """
  A custom login function which also checks to see if the user's
  account has been confirmed yet.
  """

  use Phauxth.Login.Base

  @doc """
  Check the user is confirmed before checking the password.

  If `confirmed_at: nil` is in the user struct, this function will return
  {:error, message}. Otherwise, it will run the default `check_pass` function.
  """
  def check_pass(%{confirmed_at: nil}, _, _, _), do: {:error, "account unconfirmed"}
  def check_pass(user, password, crypto, opts) do
    super(user, password, crypto, opts)
  end
end
