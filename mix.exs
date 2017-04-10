defmodule Phauxth.Mixfile do
  use Mix.Project

  def project do
    [app: :phauxth,
     version: "0.1.0",
     elixir: "~> 1.4",
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:cowboy, "~> 1.1"},
     {:plug, "~> 1.3"},
     {:comeonin, "~> 3.0"},
     {:ecto, "~> 2.1"},
     {:postgrex, "~> 0.13", optional: true},
     {:earmark, "~> 1.1", only: :dev},
     {:ex_doc,  "~> 0.14", only: :dev}]
  end
end
