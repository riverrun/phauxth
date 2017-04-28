defmodule <%= base %>.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias <%= base %>.Repo

  alias <%= base %>.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def get_by(attrs) do
    Repo.get_by(User, attrs)
  end<%= if confirm do %>

  def create_user(attrs \\ %{}, key) do<% else %>
  def create_user(attrs \\ %{}) do<% end %>
    %User{}
    |> user_changeset(attrs)
    |> Phauxth.Login.DB_Utils.add_password_hash(attrs)<%= if confirm do %>
    |> PhauxthConfirm.DB_Utils.add_confirm_token(key)<% end %>
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> user_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    user_changeset(user, %{})
  end<%= if confirm do %>

  def request_pass_reset(%{"email" => email}, key) do
    with %User{} = user <- Repo.get_by(User, email: email) do
      PhauxthConfirm.DB_Utils.add_reset_token(user, key) |> Repo.update()
    else
      nil -> {:error, :not_found}
    end
  end<% end %>

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
