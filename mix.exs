defmodule Phauxth.Mixfile do
  use Mix.Project

  @version "0.12.0"

  @description """
  Authentication library for Phoenix web applications
  """

  def project do
    [
      app: :phauxth,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
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
      {:phoenix, "~> 1.3.0-rc"},
      {:argon2_elixir, "~> 0.12", optional: true},
      {:bcrypt_elixir, "~> 0.1", optional: true},
      {:pbkdf2_elixir, "~> 0.8", optional: true},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc,  "~> 0.16", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/riverrun/phauxth",
        "Docs" => "http://hexdocs.pm/phauxth"}
    ]
  end
end
