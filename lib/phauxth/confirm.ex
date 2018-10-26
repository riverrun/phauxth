defmodule Phauxth.Confirm do
  @moduledoc """
  Module to provide user confirmation for new users.

  See the documentation for the `verify` function for details.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report(%{} = user, meta) do
    if user.confirmed_at do
      Log.warn(%Log{user: user.id, message: "user already confirmed", meta: meta})
      {:error, Config.user_messages().already_confirmed()}
    else
      super(user, meta)
    end
  end

  def report(result, meta), do: super(result, meta)
end
