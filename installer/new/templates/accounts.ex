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
    %User{}<%= if confirm do %>
    |> create_changeset(attrs, key)<% else %>
    |> create_changeset(attrs)<% end %>
    |> Repo.insert()
  end<%= if confirm do %>

  def confirm_user(%User{} = user) do
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> Repo.update
  end<% end %>

  def update_user(%User{} = user, attrs) do
    user
    |> update_changeset(attrs)
    |> Repo.update()
  end<%= if confirm do %>

  def update_password(%User{} = user, attrs) do
    user
    |> update_changeset(attrs)
    |> put_pass_hash()
    |> change(%{reset_token: nil, reset_sent_at: nil})
    |> Repo.update()
  end<% end %>

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    user_changeset(user, %{})
  end<%= if confirm do %>

  def add_reset_token(%{"email" => email}, key) do
    with %User{} = user <- Repo.get_by(User, email: email) do
      change(user, %{reset_token: key, reset_sent_at: Ecto.DateTime.utc})
      |> Repo.update()
    else
      nil -> {:error, :not_found}
    end
  end<% end %>

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end<%= if confirm do %>

  defp create_changeset(%User{} = user, attrs, key) do<% else %>
  defp create_changeset(%User{} = user, attrs) do<% end %>
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)<%= if confirm do %>
    |> change(%{confirmation_token: key, confirmation_sent_at: Ecto.DateTime.utc})<% end %>
    |> put_pass_hash()
  end

  defp update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, %{password_hash: Comeonin.Bcrypt.hashpwsalt(password), password: nil})
  end
  defp put_pass_hash(changeset), do: changeset
end
