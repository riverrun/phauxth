defmodule Phauxth.Confirm.PassResetTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Confirm, TestAccounts, Token}

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key()
    valid_email = Token.sign(conn, %{"email" => "froderick@example.com"})
    {:ok, %{conn: conn, valid_email: valid_email}}
  end

  test "reset password succeeds", %{valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:ok, user} = Confirm.verify(params, TestAccounts, mode: :pass_reset)
    assert user
  end

  test "reset password fails with expired token", %{valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:error, message} = Confirm.verify(params, TestAccounts, max_age: -1, mode: :pass_reset)
    assert message =~ "Invalid credentials"
  end

  test "reset fails when reset_sent_at is not found", %{conn: conn} do
    assert capture_log(fn ->
             valid_key = Token.sign(conn, %{"email" => "igor@example.com"})
             params = %{"key" => valid_key, "password" => "password"}
             {:error, _} = Confirm.verify(params, TestAccounts, mode: :pass_reset)
           end) =~ ~s([warn]  user=nil message="no reset token found")
  end
end
