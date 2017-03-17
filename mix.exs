defmodule ExOvh.Mixfile do
  use Mix.Project
  @version "0.3.2"
  @elixir "~> 1.3 or ~> 1.4 or ~> 1.5"

  def project do
    [
      app: :ex_ovh,
      name: "ExOvh",
      version: @version,
      source_url: "https://github.com/stephenmoloney/ex_ovh",
      elixir:  @elixir,
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
      applications: [:calendar, :crypto, :hackney, :logger]
    ]
  end

  defp deps() do
    [
      {:calendar, "~> 0.17"},
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0"},
      {:httpipe_adapters_hackney, "~> 0.9"},
      {:floki, ">= 0.7.0"},

      {:markdown, github: "devinus/markdown", only: :dev},
      {:ex_doc,  "~> 0.14", only: :dev}
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
      files: ~w(lib mix.exs README* LICENCE* CHANGELOG*)
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
