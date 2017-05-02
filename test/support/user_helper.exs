defmodule Phauxth.UserHelper do

  import Ecto.Changeset
  alias Phauxth.{TestRepo, TestUser}

  @attrs %{email: "fred+1@mail.com", username: "fred", phone: "55555555555",
    role: "user", password: "h4rd2gU3$$", confirmed_at: nil,
    confirmation_sent_at: Ecto.DateTime.utc, reset_sent_at: Ecto.DateTime.utc}
  @key "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"

  def add_user(attrs \\ @attrs) do
    %TestUser{}
    |> user_changeset(attrs)
    |> TestRepo.insert!
  end

  def add_confirm_user(attrs \\ @attrs, key \\ @key) do
    %TestUser{}
    |> user_changeset(attrs)
    |> add_confirm_token(key)
    |> TestRepo.insert!
  end

  def add_reset_user(attrs, key \\ @key) do
    %TestUser{}
    |> user_changeset(attrs)
    |> add_reset_token(key)
    |> TestRepo.insert!
  end

  def add_custom_user(attrs) do
    %TestUser{}
    |> cast(%{email: "froderick@mail.com"}, [:email])
    |> change(attrs)
    |> TestRepo.insert!
  end

  def add_confirm_token(user, key \\ @key) do
    change(user, %{confirmation_token: key, confirmation_sent_at: Ecto.DateTime.utc})
  end

  def add_reset_token(user, key \\ @key) do
    change(user, %{reset_token: key, reset_sent_at: Ecto.DateTime.utc})
  end

  def confirm_user(user) do
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> TestRepo.update!
  end

  def reset_password(user, password) do
    change(user, %{password_hash: Comeonin.Bcrypt.hashpwsalt(password)})
    |> TestRepo.update!
  end

  defp user_changeset(user, params) do
    user
    |> cast(params, Map.keys(params))
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: pass}} = changeset) do
    put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
  end
  defp put_pass_hash(changeset), do: changeset
end
