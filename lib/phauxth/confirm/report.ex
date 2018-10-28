defmodule Phauxth.Confirm.Report do
  @moduledoc """
  Log and report information and errors.
  """

  alias Phauxth.{Config, Log}

  @doc """
  Print out a log message and then return {:ok, user} or
  {:error, message} to the calling function.
  """
  def report(%{reset_sent_at: nil}, :pass_reset, meta) do
    Log.warn(%Log{message: "no reset token found", meta: meta})
    {:error, Config.user_messages().invalid_token()}
  end

  def report(%{reset_sent_at: time} = user, :pass_reset, meta) when not is_nil(time) do
    Log.info(%Log{user: user.id, message: "user confirmed for password reset", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end

  def report(%{confirmed_at: nil} = user, _, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end

  def report(%{} = user, _, meta) do
    Log.warn(%Log{user: user.id, message: "user already confirmed", meta: meta})
    {:error, Config.user_messages().already_confirmed()}
  end

  def report({:error, message}, _, meta) do
    Log.warn(%Log{message: message, meta: meta})
    {:error, Config.user_messages().default_error()}
  end

  def report(nil, _, meta), do: report({:error, "no user found"}, nil, meta)
end
