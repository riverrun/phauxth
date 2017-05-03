defmodule Phauxth.Confirm.LoginTest do
  use Phauxth.TestCase
  use Plug.Test

  alias Phauxth.UserHelper

  setup do
    attrs = %{email: "ray@mail.com", role: "user", password: "h4rd2gU3$$",
      confirmed_at: Ecto.DateTime.utc}
    key = "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
    UserHelper.add_user()
    UserHelper.add_confirm_user(attrs, key)
    |> UserHelper.confirm_user
    :ok
  end

  def login(name, password) do
    conn(:post, "/login",
         %{"session" => %{"email" => name, "password" => password}})
    |> Phauxth.Confirm.Login.call({:email, "email"})
  end

  test "login succeeds if account has been confirmed" do
    conn = login("ray@mail.com", "h4rd2gU3$$")
    %{email: email} = conn.private[:phauxth_user]
    assert email == "ray@mail.com"
  end

  test "login fails when account is not yet confirmed" do
    conn = login("fred+1@mail.com", "h4rd2gU3$$")
    assert conn.private[:phauxth_error] =~ "have to confirm your account"
  end

  test "login fails for incorrect password" do
    conn = login("ray", "oohwhatwasitagain")
    assert conn.private[:phauxth_error] =~ "Invalid credentials"
  end

end
