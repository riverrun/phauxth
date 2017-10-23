defmodule Phauxth.New.Mixfile do
  use Mix.Project

  @version "1.2.0"

  def project do
    [
      app: :phauxth_new,
      version: @version,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      elixir: "~> 1.4"
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp build_releases(_) do
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run([])
    Mix.Tasks.Archive.Build.run(["--output=phauxth_new.ez"])
    File.rename("phauxth_new.ez", "../archives/phauxth_new.ez")
    File.rename("phauxth_new-#{@version}.ez", "../archives/phauxth_new-#{@version}.ez")
  end

  defp aliases do
    [
      build: [&build_releases/1]
    ]
  end
end
