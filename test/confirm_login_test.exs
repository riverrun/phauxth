defmodule Phauxth.Confirm.LoginTest do
  use Phauxth.TestCase
  use Plug.Test

  alias Phauxth.{TestAccounts, UserHelper}

  setup do
    attrs = %{email: "ray@mail.com", role: "user", password: "h4rd2gU3$$",
      confirmed_at: Ecto.DateTime.utc}
    key = "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
    UserHelper.add_user()
    UserHelper.add_confirm_user(attrs, key)
    |> UserHelper.confirm_user
    :ok
  end

  def login(name, password, identifier \\ :email, user_params \\ "email") do
    params = %{user_params => name, "password" => password}
    Phauxth.Confirm.Login.verify(params, [identifier: identifier, user_data: TestAccounts])
  end

  test "login succeeds if account has been confirmed" do
    {:ok, %{email: email}} = login("ray@mail.com", "h4rd2gU3$$")
    assert email == "ray@mail.com"
  end

  test "login fails when account is not yet confirmed" do
    {:error, message} = login("fred+1@mail.com", "h4rd2gU3$$")
    assert message =~ "Invalid credentials"
  end

  test "login fails for incorrect password" do
    {:error, message} = login("ray", "oohwhatwasitagain")
    assert message =~ "Invalid credentials"
  end

end
