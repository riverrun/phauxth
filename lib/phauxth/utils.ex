defmodule Phauxth.Utils do
  @moduledoc false

  def default_user_context do
    project_string()
    |> Macro.camelize
    |> Module.concat(Accounts)
  end

  defp project_string do
    Mix.Project.config
    |> Keyword.fetch!(:app)
    |> to_string
  end
end
