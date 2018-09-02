defmodule Phauxth.Confirm.LoginTest do
  use ExUnit.Case
  use Plug.Test

  defp login(name, password, user_params \\ "email") do
    params = %{user_params => name, "password" => password}
    Phauxth.Confirm.Login.verify(params)
  end

  test "login succeeds if account has been confirmed" do
    {:ok, %{email: email}} = login("ray@example.com", "h4rd2gU3$$")
    assert email == "ray@example.com"
  end

  test "login fails when account is not yet confirmed" do
    {:error, message} = login("fred+1@example.com", "h4rd2gU3$$")
    assert message =~ "account needs to be confirmed"
  end

  test "login fails for incorrect password" do
    {:error, message} = login("ray", "oohwhatwasitagain")
    assert message =~ "Invalid credentials"
  end
end
