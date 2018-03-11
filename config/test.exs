use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elm_scrabble, ElmScrabbleWeb.Endpoint,
  http: [port: 4001],
  server: false

# Scrabble Dictionary Api config
config :elm_scrabble, :dictionary_api, FakeDictionaryApi

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :elm_scrabble, ElmScrabble.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES"),
  database: "elm_scrabble_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
