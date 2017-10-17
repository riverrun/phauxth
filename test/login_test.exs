defmodule Phauxth.LoginTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Login, TestAccounts}

  test "login succeeds with email" do
    params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts)
    assert email == "fred+1@example.com"
  end

  test "login succeeds with username" do
    params = %{"username" => "fred", "password" => "h4rd2gU3$$"}
    {:ok, %{username: username}} = Login.verify(params, TestAccounts)
    assert username == "fred"
  end

  test "login fails for incorrect password" do
    params = %{"email" => "fred+1@example.com", "password" => "oohwhatwasitagain"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid username" do
    params = %{"username" => "dick", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    params = %{"email" => "dick@example.com", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "output to current_user does not contain password_hash" do
    params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
    {:ok, user} = Login.verify(params, TestAccounts)
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

  test "login with different crypto module" do
    params = %{"email" => "frank@example.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts, crypto: Comeonin.Argon2)
    assert email == "frank@example.com"
  end

  test "login with different crypto module fails for wrong password" do
    params = %{"email" => "frank@example.com", "password" => "password"}
    {:error, message} = Login.verify(params, TestAccounts, crypto: Comeonin.Argon2)
    assert message =~ "Invalid credentials"
  end

  test "login with encrypted_password set as key" do
    params = %{"email" => "eddie@example.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts, crypto: Comeonin.Argon2)
    assert email == "eddie@example.com"
  end

  test "login with additional information to use different schemas" do
    params = %{"email" => "brian@example.com", "role" => "user", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email, role: role}} = Login.verify(params, TestAccounts)
    assert email == "brian@example.com"
    assert role == "user"
    params = %{"email" => "brian@example.com", "role" => "admin", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email, role: role}} = Login.verify(params, TestAccounts)
    assert email == "brian@example.com"
    assert role == "admin"
  end

  test "login with custom metadata for logging" do
    assert capture_log(fn ->
      params = %{"email" => "fred+1@example.com", "password" => "h4rd2gU3$$"}
      {:ok, _} = Login.verify(params, TestAccounts, log_meta: [path: "/sessions/create"])
    end) =~ ~s(user=1 message="successful login" path=/sessions/create)
  end

  test "raises an error if no password is found in the params" do
    assert_raise ArgumentError, "No password found in the params", fn ->
      {:ok, _} = Login.verify(%{"no_key" => "no_key"}, TestAccounts)
    end
  end

  test "add_session adds phauxth_session_id to conn" do
    session_id = conn(:get, "/")
                 |> Phauxth.SessionHelper.sign_conn
                 |> assign(:current_user, %{id: 2})
                 |> Login.add_session(Login.gen_session_id(2, "F"))
                 |> get_session(:phauxth_session_id)
    <<"F", _session_id::binary-size(16), user_id::binary>> = session_id
    assert user_id == "2"
  end

end
