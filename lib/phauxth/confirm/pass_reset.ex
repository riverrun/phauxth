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
end
