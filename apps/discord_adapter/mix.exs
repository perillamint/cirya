defmodule Hedwig.Adapters.Discord.Mixfile do
  use Mix.Project

  def project do
    [
      app: :discord_adapter,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :nostrum]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
      {:nostrum, "~> 0.2.1"},
      {:gun, git: "https://github.com/ninenines/gun.git", ref: "dd1bfe4d6f9fb277781d922aa8bbb5648b3e6756", override: true}
    ]
  end
end
