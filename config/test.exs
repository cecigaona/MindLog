import Config

# Docker supplies TEST_DATABASE_URL with the `db` service hostname. The fallback
# supports a local PostgreSQL test database with the generated credentials.
test_database_url =
  System.get_env("TEST_DATABASE_URL") || "ecto://postgres:postgres@localhost:5432/mindlog_test"

config :mindlog, Mindlog.Repo,
  url: test_database_url,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mindlog, MindlogWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "R2M/3I/yFVIgv4dXRNaJSnZwBd+ouu9wfqaXcHQdj8EYqe+r9oZnARVDRzkfBfEZ",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
