defmodule <%= base %>.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string<%= if confirm do %>
    field :confirmed_at, :utc_datetime
    field :confirmation_token, :string
    field :confirmation_sent_at, :utc_datetime
    field :reset_token, :string
    field :reset_sent_at, :utc_datetime<% end %>

    timestamps()
  end
end
