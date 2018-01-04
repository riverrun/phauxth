defmodule Phauxth.Confirm.Login do
  @moduledoc """
  A custom login module which also checks to see if the user's
  account has been confirmed yet.

  When calling the `verify/3` function, if `confirmed_at: nil` is in the
  user struct, this function will return {:error, message}. If the account
  has been confirmed, the default `check_pass` function will be run.
  """

  use Phauxth.Login.Base

  @impl true
  def check_pass(%{confirmed_at: nil}, _, _, _), do: {:error, "account unconfirmed"}

  def check_pass(user, password, crypto, opts) do
    super(user, password, crypto, opts)
  end

  @impl true
  def report({:error, "account unconfirmed"}, _, meta) do
    Log.warn(%Log{message: "account unconfirmed", meta: meta})
    {:error, Config.user_messages().need_confirm()}
  end

  def report(result, ok_message, meta) do
    super(result, ok_message, meta)
  end
end
