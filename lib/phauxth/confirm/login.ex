defmodule Phauxth.Confirm.Login do
  @moduledoc """
  A custom Login function which also checks to see if the user's
  account has been confirmed yet.
  """

  use Phauxth.Login.Base

  def check_pass(%{confirmed_at: nil}, _, _),
    do: {:error, "account unconfirmed"}
  def check_pass(user, password, opts), do: super(user, password, opts)
end
