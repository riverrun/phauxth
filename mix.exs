defmodule Phauxth.Mixfile do
  use Mix.Project

  @version "2.0.0"

  @description """
  Authentication library for Phoenix, and other Plug-based, web applications
  """

  def project do
    [
      app: :phauxth,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      name: "Phauxth",
      description: @description,
      package: package(),
      source_url: "https://github.com/riverrun/phauxth",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.5"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/riverrun/phauxth"}
    ]
  end
end
