defmodule Phauxth.UserHelper do

  import Ecto.Changeset
  alias Phauxth.{TestRepo, TestUser}

  def add_user do
    attrs = %{email: "fred+1@mail.com", username: "fred", phone: "55555555555",
      role: "user", password: "h4rd2gU3$$", confirmed_at: nil,
      confirmation_sent_at: Ecto.DateTime.utc, reset_sent_at: Ecto.DateTime.utc}
    %TestUser{} |> add_user(attrs, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw", TestRepo)
  end

  def add_confirmed do
    attrs = %{email: "ray@mail.com", role: "user", password: "h4rd2gU3$$",
      confirmed_at: Ecto.DateTime.utc}
    %TestUser{} |> add_user_confirmed(attrs, TestRepo)
  end

  def add_custom_crypto_user do
    %TestUser{}
    |> cast(%{email: "froderick@mail.com"}, [:email])
    |> change(%{password_hash: "dumb-h4rd2gU3$$-crypto"})
    |> TestRepo.insert!
  end

  def add_custom_hashname_user do
    %TestUser{}
    |> cast(%{email: "igor@mail.com"}, [:email])
    |> change(%{encrypted_password: "dumb-h4rd2gU3$$-crypto"})
    |> TestRepo.insert!
  end

  def add_otp_user do
    attrs = %{email: "brian@mail.com", role: "user", password: "h4rd2gU3$$",
      otp_required: true, otp_secret: "MFRGGZDFMZTWQ2LK", otp_last: 0}
    %TestUser{} |> add_user(attrs, TestRepo)
  end

  def add_reset_user(key) do
    attrs = %{email: "frank@mail.com", role: "user", password: "h4rd2gU3$$",
      confirmed_at: Ecto.DateTime.utc}
    %TestUser{} |> add_reset(attrs, key, TestRepo)
  end

  defp add_user(user, attrs, repo) do
    user_changeset(user, attrs) |> repo.insert!
  end
  defp add_user(user, attrs, key, repo) do
    user_changeset(user, attrs)
    |> Phauxth.Confirm.DB_Utils.add_confirm_token(key)
    |> repo.insert!
  end

  defp add_user_confirmed(user, attrs, repo) do
    add_user(user, attrs, repo)
    |> change(%{confirmed_at: Ecto.DateTime.utc})
    |> repo.update!
  end

  defp add_reset(user, attrs, key, repo) do
    user_changeset(user, attrs)
    |> Phauxth.Confirm.DB_Utils.add_reset_token(key)
    |> repo.insert!
  end

  defp user_changeset(user, params) do
    user
    |> cast(params, Map.keys(params))
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> Phauxth.Login.DB_Utils.add_password_hash(params)
  end
end
