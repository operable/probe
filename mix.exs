defmodule Probe.Mixfile do
  use Mix.Project

  def project do
    [app: :probe,
     version: "0.0.1",
     elixir: "~> 1.1",
     elixirc_options: [warnings_as_errors: System.get_env("ALLOW_WARNINGS") == nil],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:mix_test_watch, "~> 0.1.1", only: :test}
    ]
  end
end
