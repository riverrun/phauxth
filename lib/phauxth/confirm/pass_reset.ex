defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Module to provide user confirmation when resetting passwords.

  See the documentation for the `verify` function for details.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report(%{} = user, meta) do
    check_reset_sent_at(user, meta)
  end

  def report(result, meta), do: super(result, meta)

  defp check_reset_sent_at(%{reset_sent_at: nil}, meta) do
    Log.warn(%Log{message: "no reset token found", meta: meta})
    {:error, Config.user_messages().default_error()}
  end

  defp check_reset_sent_at(%{reset_sent_at: _time} = user, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed for password reset", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end
end
