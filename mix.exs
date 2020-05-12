defmodule JTIRegister.MixProject do
  use Mix.Project

  def project do
    [
      app: :jti_register,
      description: "Tesla middlewares for OAuth2 and OpenID Connect client authentication",
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      deps: deps(),
      package: package(),
      source_url: "https://github.com/tanguilp/jti_register"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  def package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/tanguilp/jti_register"}
    ]
  end
end
