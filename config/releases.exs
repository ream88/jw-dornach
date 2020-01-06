import Config

config :dornach, DornachWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: "jw-dornach.at", port: 443]
