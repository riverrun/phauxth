defmodule Phauxth.Mixfile do
  use Mix.Project

  @version "1.2.2"

  @description """
  Authentication library for Phoenix, and other Plug-based, web applications
  """

  def project do
    [
      app: :phauxth,
      version: @version,
      elixir: "~> 1.4",
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
      {:plug, "~> 1.4"},
      {:comeonin, "~> 4.0"},
      {:poison, "~> 3.1"},
      {:argon2_elixir, "~> 1.2", optional: true},
      {:bcrypt_elixir, "~> 0.12.1 or ~> 1.0", optional: true},
      {:pbkdf2_elixir, "~> 0.12", optional: true},
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
