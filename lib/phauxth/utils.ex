defmodule Phauxth.Utils do
  @moduledoc """
  """

  def default_repo do
    base_module() |> Module.concat(Repo)
  end

  def default_user_schema do
    base_module() |> Module.concat(Accounts.User)
  end

  @doc """
  """
  def base_module do
    Mix.Project.config
    |> Keyword.fetch!(:app)
    |> to_string
    |> Macro.camelize
  end

end
