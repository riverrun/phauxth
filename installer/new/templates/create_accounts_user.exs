defmodule <%= base %>.Repo.Migrations.Create<%= base %>.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :email, :string
      add :password_hash, :string<%= if confirm do %>
      add :confirmed_at, :utc_datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :utc_datetime
      add :reset_token, :string
      add :reset_sent_at, :utc_datetime<% end %>

      timestamps()
    end

    create unique_index :accounts_users, [:email]
  end
end
