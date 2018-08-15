defmodule Phauxth.Confirm.PassResetTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Config, Confirm.PassReset, TestAccounts}
  alias Phoenix.Token

  @endpoint Config.endpoint()
  @user_salt Config.token_salt()

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key()
    valid_email = Token.sign(@endpoint, @user_salt, %{"email" => "froderick@example.com"})
    {:ok, %{conn: conn, valid_email: valid_email}}
  end

  test "reset password succeeds", %{valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:ok, user} = PassReset.verify(params, TestAccounts)
    assert user
  end

  test "reset password fails with expired token" do
    expired_email = Token.sign(@endpoint, @user_salt, %{"email" => "froderick@example.com"})
    params = %{"key" => expired_email, "password" => "password"}
    {:error, message} = PassReset.verify(params, TestAccounts, max_age: -1)
    assert message =~ "Invalid credentials"
  end

  test "reset fails when reset_sent_at is not found" do
    assert capture_log(fn ->
             valid_key = Token.sign(@endpoint, @user_salt, %{"email" => "igor@example.com"})
             params = %{"key" => valid_key, "password" => "password"}
             {:error, _} = PassReset.verify(params, TestAccounts)
           end) =~ ~s([warn]  user=nil message="no reset token found")
  end
end
