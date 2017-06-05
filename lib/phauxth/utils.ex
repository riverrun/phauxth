defmodule Phauxth.Utils do
  @moduledoc """
  """

  @doc """
  The default repo.
  """
  def default_repo do
    base_module() |> Module.concat(Repo)
  end

  @doc """
  The default user schema.
  """
  def default_user_schema do
    base_module() |> Module.concat(Accounts.User)
  end

  defp base_module do
    Mix.Project.config
    |> Keyword.fetch!(:app)
    |> to_string
    |> Macro.camelize
  end

end
