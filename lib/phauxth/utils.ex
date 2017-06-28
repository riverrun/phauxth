defmodule Phauxth.Utils do
  @moduledoc """
  Tools for use with Phauxth.
  """

  @doc """
  """
  def default_user_data do
    base_module() |> Module.concat(Accounts)
  end

  defp base_module do
    Mix.Project.config
    |> Keyword.fetch!(:app)
    |> to_string
    |> Macro.camelize
  end
end
