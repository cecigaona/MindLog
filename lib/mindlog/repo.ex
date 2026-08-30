defmodule Mindlog.Repo do
  use Ecto.Repo,
    otp_app: :mindlog,
    adapter: Ecto.Adapters.Postgres
end
