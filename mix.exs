defmodule Zfls.MixProject do
  use Mix.Project

  @app :zfls
  #@source_url "https://github.com/tynanbe/#{@app}"

  def project do
    [
      app: @app,
      version: "0.1.0",
      description: "Format and colorize ZFS list results",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      erlc_paths: ["src", "gen"],
      compilers: [:gleam | Mix.compilers()],
      deps: deps(),
      escript: escript(),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps do
    [
      #{:gleam_stdlib, "~> 0.13"},
      {:gleam_stdlib, github: "gleam-lang/stdlib", branch: "main", override: true},
      {:mix_gleam, "~> 0.1"},
      {:shellout, "~> 0.1"},
    ]
  end

  defp escript do
    [
      main_module: @app,
      path: "_build/default/bin/#{@app}",
    ]
  end
end
