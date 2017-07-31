defmodule Phauxth.Utils do
  @moduledoc false

  def default_user_context do
    Mix.Project.config
    |> Keyword.fetch!(:app)
    |> to_string
    |> Macro.camelize
    |> Module.concat(Accounts)
  end
end
