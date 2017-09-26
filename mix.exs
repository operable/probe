defmodule Probe.Mixfile do
  use Mix.Project

  def project do
    [app: :probe,
     version: "1.1.0",
     elixir: "~> 1.5.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.html": :test,
                         "coveralls.travis": :test],
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {Probe, []}]
  end

  defp deps do
    [{:poison, "~> 3.1"},
     {:ex_doc, "~> 0.16", only: :dev},
     {:earmark, "~> 1.2", only: :dev},
     {:excoveralls, "~> 0.7", only: :test}]
  end
end
