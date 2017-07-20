defmodule Phauxth.Confirm.PassResetTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Confirm.PassReset, TestAccounts}

  def call_reset(name, password, opts) do
    params = %{"email" => "#{name}@mail.com",
      "key" => "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw",
      "password" => password}
    PassReset.verify(params, TestAccounts, opts)
  end

  test "reset password succeeds" do
    password = "my N1pples expl0de with the light!"
    {:ok, user} = call_reset("froderick", password, [key_validity: 60])
    assert user
  end

  test "reset password fails with expired token" do
    password = "C'est bon, la vie"
    {:error, message} = call_reset("froderick", password, [key_validity: 0])
    assert message =~ "Invalid credentials"
  end

  test "reset password fails when reset_sent_at is nil" do
    {:error, message} = call_reset("igor", "password", [key_validity: 60])
    assert message =~ "Invalid credentials"
  end

end
