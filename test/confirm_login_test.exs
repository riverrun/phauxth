defmodule Phauxth.Confirm.LoginTest do
  use ExUnit.Case
  use Plug.Test

  def login(name, password, identifier \\ :email, user_params \\ "email") do
    params = %{user_params => name, "password" => password}
    Phauxth.Confirm.Login.verify(params, Phauxth.TestAccounts, [identifier: identifier])
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
