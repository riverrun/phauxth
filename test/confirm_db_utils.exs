defmodule Phauxth.Confirm.DB_UtilsTest do
  use Phauxth.TestCase
  use Plug.Test

  alias Phauxth.{TestRepo, TestUser}
  alias Phauxth.Confirm.DB_Utils

  setup do
    user = %TestUser{email: "eddybaby@mail.com",
      confirmation_token: nil, confirmation_sent_at: nil}
      |> TestRepo.insert!
    token = "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
    {:ok, %{user: user, token: token}}
  end

  test "add_confirm_token", %{user: user, token: token} do
    %{changes: changes} = DB_Utils.add_confirm_token(user, token)
    assert changes.confirmation_token
    assert changes.confirmation_sent_at
  end

  test "add_reset_token", %{token: token} do
    user = %TestUser{email: "reg@mail.com", password: "h4rd2gU3$$", confirmed_at: Ecto.DateTime.utc}
    %{changes: changes} = DB_Utils.add_reset_token(user, token)
    assert changes.reset_token
    assert changes.reset_sent_at
  end

  test "check time" do
    assert DB_Utils.check_time(Ecto.DateTime.utc, 60)
    refute DB_Utils.check_time(Ecto.DateTime.utc, -60)
    refute DB_Utils.check_time(nil, 60)
  end

  test "user confirmed", %{user: user} do
    {:ok, user} = DB_Utils.user_confirmed(user)
    assert user.confirmed_at
  end

end
