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

  def get(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end<%= if confirm do %>

  def confirm_user(%User{} = user) do
    change(user, %{confirmed_at: DateTime.utc_now})
      |> Repo.update
  end<% end %>

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_password(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> User.put_pass_hash()
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
