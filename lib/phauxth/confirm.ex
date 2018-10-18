defmodule Phauxth.Confirm do
  @moduledoc """
  Module to provide user confirmation for new users.

  See the documentation for the `verify` function for details.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report(%{} = user, meta) do
    check_user_confirmed(user, meta)
  end

  def report(result, meta), do: super(result, meta)

  defp check_user_confirmed(%{confirmed_at: nil} = user, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end

  defp check_user_confirmed(%{} = user, meta) do
    Log.warn(%Log{user: user.id, message: "user already confirmed", meta: meta})
    {:error, Config.user_messages().already_confirmed()}
  end
end
