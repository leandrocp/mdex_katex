defmodule MDExKatex.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/mdex_katex"
  @version "0.1.0-dev"

  def project do
    [
      app: :mdex_katex,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases(),
      name: "MDExKatex",
      source_url: @source_url,
      description: "MDEx plugin for KaTeX (math formulas)",
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [
        docs: :docs,
        "hex.publish": :docs
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Leandro Pereira"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/mdex_katex/changelog.html",
        GitHub: @source_url
      },
      files: ~w[
        mix.exs
        lib
        README.md
        LICENSE
        CHANGELOG.md
        usage-rules.md
      ]
    ]
  end

  defp docs do
    [
      main: "MDExKatex",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["CHANGELOG.md"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp deps do
    [
      mdex_dep(),
      {:ex_doc, ">= 0.0.0", only: :docs},
      {:makeup_elixir, "~> 1.0", only: :docs}
    ]
  end

  defp mdex_dep do
    if path = System.get_env("MDEX_PATH") do
      {:mdex, path: path}
    else
      {:mdex, "~> 0.9"}
    end
  end

  defp aliases do
    [
      setup: ["deps.get", "compile"]
    ]
  end
end
