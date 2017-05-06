defmodule Phauxth.Mixfile do
  use Mix.Project

  @version "0.9.0"

  @description """
  Authentication library for Phoenix web applications
  """

  def project do
    [app: :phauxth,
     version: @version,
     elixir: "~> 1.4",
     start_permanent: Mix.env == :prod,
     name: "Phauxth",
     description: @description,
     package: package(),
     source_url: "https://github.com/riverrun/phauxth",
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:phoenix, "~> 1.3.0-rc"},
     {:ecto, "~> 2.1"},
     {:cowboy, "~> 1.1"},
     {:comeonin, "~> 3.0"},
     {:postgrex, "~> 0.13", optional: true},
     {:earmark, "~> 1.2", only: :dev},
     {:ex_doc,  "~> 0.15", only: :dev}]
  end

  defp package do
    [maintainers: ["David Whitlock"],
     licenses: ["BSD"],
     links: %{"GitHub" => "https://github.com/riverrun/phauxth",
      "Docs" => "http://hexdocs.pm/phauxth"}]
  end
end
