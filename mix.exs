defmodule ExOvh.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_ovh,
      name: "ExOvh",
      version: "0.0.1",
      source_url: "https://github.com/stephenmoloney/ex_ovh",
      elixir: "~> 1.1",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
     ]
  end

  def application() do
    [
      mod: [],
      applications: [:calendar, :crypto, :logger, :openstex]
    ]
  end

  defp deps() do
    [
      {:secure_random, "~> 0.2"},
      {:floki, "~> 0.7.1"},
      {:calendar, "~> 0.13.2"},
      {:og, "~> 0.1"},
      # {:openstex, github: "stephenmoloney/openstex", branch: "master"}, # incorporates :poison and httpoison
      {:openstex, path: "../openstex"},

      {:earmark, "~> 0.2.1", only: :dev},
      {:ex_doc,  "~> 0.11", only: :dev}
    ]
  end

  defp description() do
    ~s"""
    An elixir client library for easier use of the Ovh api.
    """
  end


  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Stephen Moloney"],
      links: %{ "GitHub" => "https://github.com/stephenmoloney/ex_ovh"},
      files: ~w(lib priv mix.exs README* LICENSE* CHANGELOG*)
     }
  end

end
