defmodule ExOvh.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_ovh,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps
     ]
  end

  def application do
    [
      mod: {ExOvh, []},
      applications: [:calendar, :crypto, :httpotion, :logger]
    ]
  end

  defp deps do
    [
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2"},
      {:httpotion, "~> 2.1"},
      {:poison, "~> 2.0"},
      {:secure_random, "~> 0.2"},
      {:floki, "~> 0.7.1"},
      {:calendar, "~> 0.12.1"},
      {:loggingutils, github: "stephenmoloney/loggingutils", only: :dev}
    ]
  end

end
