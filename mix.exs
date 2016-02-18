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
      applications: [:calendar, :crypto, :httpotion, :logger]
    ]
  end

  defp deps() do
    [
      {:httpotion, "~> 2.2"},
      {:poison, "~> 2.0"},
      {:secure_random, "~> 0.2"},
      {:floki, "~> 0.7.1"},
      {:calendar, "~> 0.12.4"},
      {:earmark, "~> 0.2.1", only: :dev},
      {:ex_doc,  "~> 0.11", only: :dev},
      {:og, "~> 0.0"}
    ]
  end

  defp description() do
    ~s"""
    An elixir client library for easier use of the Hubic api and Ovh api.
    """
  end


  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Stephen Moloney"],
      links: %{ "GitHub" => "https://github.com/stephenmoloney/ex_ovh"},
      files: ~w(lib priv mix.exs README* LICENSE* CHANGELOG* changelog* src)
     }
  end

end
