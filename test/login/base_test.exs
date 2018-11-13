defmodule Phauxth.Login.BaseTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.Login

  test "login succeeds with email" do
    params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params)
    assert email == "fred+1@example.com"
  end

  test "login succeeds with username" do
    params = %{"username" => "fred", "password" => "h4rd2gU3$$"}
    {:ok, %{username: username}} = Login.verify(params)
    assert username == "fred"
  end

  test "login fails for incorrect password" do
    params = %{"email" => "fred+1@example.com", "password" => "oohwhatwasitagain"}
    {:error, message} = Login.verify(params)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid username" do
    params = %{"username" => "dick", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    params = %{"email" => "dick@example.com", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params)
    assert message =~ "Invalid credentials"
  end

  test "output to current_user does not contain password_hash" do
    params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
    {:ok, user} = Login.verify(params)
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

  test "login with custom metadata for logging" do
    assert capture_log(fn ->
             params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
             {:ok, _} = Login.verify(params, log_meta: [path: "/sessions/create"])
           end) =~ ~s(user=1 message="successful login" path=/sessions/create)
  end

  test "raises an error if no password is found in the params" do
    assert_raise ArgumentError, "No password found in the params", fn ->
      {:ok, _} = Login.verify(%{"no_key" => "no_key"})
    end
  end

  test "set user_context in the keyword args" do
    params = %{"email" => "deirdre@example.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, user_context: Phauxth.OtherTestUsers)
    assert email == "deirdre@example.com"
    params = %{"email" => "deirdre@example.com", "password" => "ohnoitisnt"}
    {:error, message} = Login.verify(params, user_context: Phauxth.OtherTestUsers)
    assert message =~ "Invalid credentials"
  end
end
