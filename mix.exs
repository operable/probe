defmodule Probe.Mixfile do
  use Mix.Project

  def project do
    [app: :probe,
     version: "1.1.0",
     elixir: "~> 1.3.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.html": :test,
                         "coveralls.travis": :test],
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Probe, []}]
  end

  defp deps do
    [{:poison, "~> 2.0"},
     {:ex_doc, "~> 0.13", only: :dev},
     {:earmark, "~> 1.0", only: :dev},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:excoveralls, "~> 0.6", only: :test}]
  end
end
