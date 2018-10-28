defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Module to provide user confirmation when resetting passwords.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report({:ok, user}, meta) do
    if log_output(user, meta) do
      {:ok, Map.drop(user, Config.drop_user_keys())}
    else
      {:error, Config.user_messages().default_error()}
    end
  end

  def report(result, meta), do: super(result, meta)

  defp log_output(%{confirmed_at: nil}, meta) do
    Log.warn(%Log{message: "unconfirmed user attempting to reset password", meta: meta})
    false
  end

  defp log_output(%{reset_sent_at: nil}, meta) do
    Log.warn(%Log{message: "no reset token found", meta: meta})
    false
  end

  defp log_output(user, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed for password reset", meta: meta})
  end
end
