defmodule Phauxth.Login.CustomLoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.CustomLogin

  test "login fails if user not confirmed" do
    params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
    assert {:error, "Invalid credentials"} = CustomLogin.verify(params)
  end

  test "login succeeds if user is confirmed" do
    params = %{"email" => "ray@example.com", "password" => "h4rd2gU3$$"}
    assert {:ok, %{email: email}} = CustomLogin.verify(params)
    assert email == "ray@example.com"
  end
end
