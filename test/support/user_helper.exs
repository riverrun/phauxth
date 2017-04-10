defmodule Phauxth.UserHelper do

  import Ecto.Changeset
  alias Phauxth.{Login.DB_Utils, TestRepo, TestUser}

  def add_user do
    attrs = %{email: "fred+1@mail.com", username: "fred", role: "user", password: "h4rd2gU3$$"}
    %TestUser{} |> user_changeset(attrs) |> TestRepo.insert!
  end

  def add_otp_user do
    attrs = %{email: "brian@mail.com", username: "brian", role: "user", password: "h4rd2gU3$$",
      otp_required: true, otp_secret: "MFRGGZDFMZTWQ2LK", otp_last: 0}
    %TestUser{} |> user_changeset(attrs) |> TestRepo.insert!
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

  defp user_changeset(user, params) do
    user
    |> cast(params, Map.keys(params))
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> DB_Utils.add_password_hash(params)
  end
end
