defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Module to provide user confirmation when resetting passwords.

  See the documentation for the `verify` function for details.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report(%{} = user, meta) do
    if user.reset_sent_at do
      Log.info(%Log{user: user.id, message: "user confirmed for password reset", meta: meta})
      {:ok, Map.drop(user, Config.drop_user_keys())}
    else
      Log.warn(%Log{message: "no reset token found", meta: meta})
      {:error, Config.user_messages().default_error()}
    end
  end

  def report(result, meta), do: super(result, meta)
end
