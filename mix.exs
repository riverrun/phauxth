defmodule Phauxth.Mixfile do
  use Mix.Project

  @version "2.3.0"

  @description """
  Authentication library for Phoenix, and other Plug-based, web applications
  """

  def project do
    [
      app: :phauxth,
      version: @version,
      elixir: "~> 1.7",
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
      {:plug, "~> 1.7"},
      {:argon2_elixir, "~> 2.0", optional: true},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false}
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
