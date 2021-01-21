defmodule Zfls.MixProject do
  use Mix.Project

  @app :zfls
  @version "0.1.0"
  #@source_url "https://github.com/tynanbe/#{@app}"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      erlc_paths: ["src", "gen"],
      compilers: [:gleam | Mix.compilers()],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:mix_gleam, "~> 0.1"},
      {:gleam_stdlib, "~> 0.13"}
    ]
  end
end
