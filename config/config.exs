# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elm_scrabble,
  ecto_repos: [ElmScrabble.Repo]

# Configures the endpoint
config :elm_scrabble, ElmScrabbleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RtSA/jp0hXlRJwVYA0H6jGcaSnwRHgOgikURpa+m73+IY7HP7Vz8/VNTr8XhJstc",
  render_errors: [view: ElmScrabbleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElmScrabble.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
