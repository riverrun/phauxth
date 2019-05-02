defmodule Phauxth.Confirm.PassResetTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Confirm.PassReset, CustomGetUserPassReset, TestToken}

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key()
    valid_email = TestToken.sign(%{"email" => "froderick@example.com"}, [])
    {:ok, %{conn: conn, valid_email: valid_email}}
  end

  test "reset password succeeds", %{valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:ok, user} = PassReset.verify(params)
    assert user
    assert user.email == "froderick@example.com"
  end

  test "reset password fails with expired token" do
    expired_email = TestToken.sign(%{"email" => "froderick@example.com"}, [])
    params = %{"key" => expired_email, "password" => "password"}
    {:error, message} = PassReset.verify(params, max_age: -1)
    assert message =~ "Invalid credentials"
  end

  test "reset fails when confirmed_at is nil" do
    assert capture_log(fn ->
             valid_key = TestToken.sign(%{"email" => "brian@example.com"}, [])
             params = %{"key" => valid_key, "password" => "password"}
             {:error, "Invalid credentials"} = PassReset.verify(params)
           end) =~ ~s([warn]  user=nil message="unconfirmed user attempting to reset password")
  end

  test "reset fails when reset_sent_at is not found" do
    assert capture_log(fn ->
             valid_key = TestToken.sign(%{"email" => "igor@example.com"}, [])
             params = %{"key" => valid_key, "password" => "password"}
             {:error, "Invalid token"} = PassReset.verify(params)
           end) =~ ~s([warn]  user=nil message="no reset token found")
  end

  test "get_user/2 can be overridden for pass_reset", %{valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:ok, user} = CustomGetUserPassReset.verify(params)
    assert user
    assert user.email == "froderick@example.com"
    assert user.current_email == "froderick@example.com"
  end
end
