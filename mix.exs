defmodule ExOvh.Mixfile do
  use Mix.Project
  @version "0.1.2"

  def project do
    [
      app: :ex_ovh,
      name: "ExOvh",
      version: @version,
      source_url: "https://github.com/stephenmoloney/ex_ovh",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
     ]
  end

  def application() do
    [
      applications: [:calendar, :crypto, :httpoison, :logger]
    ]
  end

  defp deps() do
    [
#    {:calendar, "~> 0.13.2"},
      {:calendar, "~> 0.14.0"},
      {:og, "~> 0.1"},
      {:morph, "~> 0.1.0"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:httpoison, "~> 0.8.0"},
      {:floki, "~> 0.7.1"},

      {:markdown, github: "devinus/markdown", only: :dev},
      {:ex_doc,  "~> 0.11", only: :dev}
    ]
  end

  defp description() do
    ~s"""
    An elixir client library for the OVH API.
    """
  end


  defp package() do
    %{
      licenses: ["MIT"],
      maintainers: ["Stephen Moloney"],
      links: %{ "GitHub" => "https://github.com/stephenmoloney/ex_ovh"},
      files: ~w(lib priv mix.exs README* LICENCE* CHANGELOG*)
     }
  end

  defp docs() do
    [
    main: "ExOvh",
    extras: [
             "docs/mix_task.md": [path: "mix_task.md", title: "Step 1: Generating the OVH application"],
             "docs/getting_started.md": [path: "getting_started.md", title: "Step 2: Setting up client"]
            ]
    ]
  end

end
