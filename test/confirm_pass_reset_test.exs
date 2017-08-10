defmodule Phauxth.Confirm.PassResetTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Confirm.PassReset, TestAccounts, Token}

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key
    valid_email = Token.sign(conn, %{"email" => "froderick@mail.com"})
    {:ok, %{conn: conn, valid_email: valid_email}}
  end

  test "reset password succeeds", %{conn: conn, valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:ok, user} = PassReset.verify(params, TestAccounts, {conn, 1200})
    assert user
  end

  test "reset password fails with expired token", %{conn: conn, valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:error, message} =  PassReset.verify(params, TestAccounts, {conn, -1})
    assert message =~ "Invalid credentials"
  end

  test "reset fails when reset_sent_at is not found", %{conn: conn} do
    valid_key = Token.sign(conn, %{"email" => "igor@mail.com"})
    params = %{"key" => valid_key, "password" => "password"}
    {:error, message} = PassReset.verify(params, TestAccounts, {conn, 1200})
    assert message =~ "user has not been sent a reset token"
  end

end
