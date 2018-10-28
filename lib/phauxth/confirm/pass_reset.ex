defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Module to provide user confirmation when resetting passwords.

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for verifying the token. See the documentation
  for the Phauxth.Token module for details.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report({:ok, user}, meta), do: log_output(user, meta)
  def report(result, meta), do: super(result, meta)

  defp log_output(%{confirmed_at: nil}, meta) do
    Log.warn(%Log{message: "unconfirmed user attempting to reset password", meta: meta})
    {:error, Config.user_messages().default_error()}
  end

  defp log_output(%{reset_sent_at: nil}, meta) do
    Log.warn(%Log{message: "no reset token found", meta: meta})
    {:error, Config.user_messages().invalid_token()}
  end

  defp log_output(user, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed for password reset", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end
end
