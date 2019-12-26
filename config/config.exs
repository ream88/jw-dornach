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
  pubsub: [name: Dornach.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :dornach, :strftime,
  day_of_week_names: fn day_of_week ->
    {"Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"}
    |> elem(day_of_week - 1)
  end,
  abbreviated_day_of_week_names: fn day_of_week ->
    {"Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"}
    |> elem(day_of_week - 1)
  end,
  month_names: fn month ->
    {"Jänner", "Feber", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober",
     "November", "Dezember"}
    |> elem(month - 1)
  end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
