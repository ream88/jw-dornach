# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Configures the endpoint
config :dornach, DornachWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ol2Bkka4ksqVlcZgk8m1daKdx2PXnbZTad5r7Od6SxVHxUIpjWLaD660fqUOhtNv",
  render_errors: [view: DornachWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dornach.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "fV2GRh3mW1Ou1fAqcDz2Ym94+JbU3SXc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :dornach, :strftime,
  day_of_week_names: &NimbleStrftime.German.day_of_week_names/1,
  abbreviated_day_of_week_names: &NimbleStrftime.German.abbreviated_day_of_week_names/1,
  month_names: &NimbleStrftime.German.month_names/1

config :dornach, google_calendar_id: {:system, "GOOGLE_CALENDAR_ID"}

config :goth, json: {:system, "GOOGLE_APPLICATION_CREDENTIALS"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
