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
end
