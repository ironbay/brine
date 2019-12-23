defmodule Brine.MixProject do
  use Mix.Project

  def project do
    [
      app: :brine,
      description: "Configuration loader for elixir",
      package: [
        licenses: ["MIT"],
        maintainers: ["ironbay"],
        links: %{Github: "https://github.com/ironbay/brine"}
      ],
      version: "0.2.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dynamic, "~> 0.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
