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
    {:ok, user} = PassReset.verify(conn, params, TestAccounts)
    assert user
  end

  test "reset password fails with expired token", %{conn: conn, valid_email: valid_email} do
    params = %{"key" => valid_email, "password" => "password"}
    {:error, message} =  PassReset.verify(conn, params, TestAccounts, [max_age: -1])
    assert message =~ "Invalid credentials"
  end

end
