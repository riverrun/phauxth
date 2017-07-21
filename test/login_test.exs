defmodule Phauxth.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{CustomLogin, Login, TestAccounts}

  test "login succeeds with email" do
    params = %{"email" => "fred+1@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts)
    assert email == "fred+1@mail.com"
  end

  test "login succeeds with username" do
    params = %{"username" => "fred", "password" => "h4rd2gU3$$"}
    {:ok, %{username: username}} = Login.verify(params, TestAccounts)
    assert username == "fred"
  end

  test "login fails for incorrect password" do
    params = %{"email" => "fred+1@mail.com", "password" => "oohwhatwasitagain"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid username" do
    params = %{"username" => "dick", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    params = %{"email" => "dick@mail.com", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "output to current_user does not contain password_hash" do
    params = %{"email" => "fred+1@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, user} = Login.verify(params, TestAccounts)
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

  test "use a custom check_pass" do
    params = %{"email" => "frank@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = CustomLogin.verify(params, TestAccounts)
    assert email == "frank@mail.com"
  end

  test "login fails for invalid email with custom check_pass" do
    params = %{"email" => "oranges@mail.com", "password" => "h4rd2gU3$$"}
    {:error, message} = CustomLogin.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "login with different crypto module" do
    params = %{"email" => "frank@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts, crypto: Comeonin.Argon2)
    assert email == "frank@mail.com"
  end

  test "login with different crypto module fails for wrong password" do
    params = %{"email" => "frank@mail.com", "password" => "password"}
    {:error, message} = Login.verify(params, TestAccounts, crypto: Comeonin.Argon2)
    assert message =~ "Invalid credentials"
  end

  test "login with encrypted_password set as key" do
    params = %{"email" => "eddie@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts, crypto: Comeonin.Argon2)
    assert email == "eddie@mail.com"
  end

  test "login with additional information to use different schemas" do
    params = %{"email" => "brian@mail.com", "role" => "user", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email, role: role}} = Login.verify(params, TestAccounts)
    assert email == "brian@mail.com"
    assert role == "user"
    params = %{"email" => "brian@mail.com", "role" => "admin", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email, role: role}} = Login.verify(params, TestAccounts)
    assert email == "brian@mail.com"
    assert role == "admin"
  end

end
