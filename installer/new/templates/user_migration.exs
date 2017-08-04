defmodule <%= base %>.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_hash, :string<%= if confirm do %>
      add :confirmed_at, :utc_datetime
      add :reset_sent_at, :utc_datetime<% end %>

      timestamps()
    end

    create unique_index :users, [:email]
  end
end
