defmodule Phauxth.LoginTest do
  use Phauxth.TestCase
  use Plug.Test

  alias Phauxth.{Login, TestAccounts, UserHelper}

  @crypto_attrs %{password_hash: "dumb-h4rd2gU3$$-crypto"}
  @hashname_attrs %{encrypted_password: "dumb-h4rd2gU3$$-crypto"}

  setup do
    UserHelper.add_user()
    :ok
  end

  test "login succeeds with email" do
    params = %{"email" => "fred+1@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Login.verify(params, TestAccounts)
    assert email == "fred+1@mail.com"
  end

  test "login succeeds with username" do
    params = %{"username" => "fred", "password" => "h4rd2gU3$$"}
    {:ok, %{username: username}} = Login.verify(params, TestAccounts, [identifier: :username])
    assert username == "fred"
  end

  test "login fails for incorrect password" do
    params = %{"email" => "fred+1@mail.com", "password" => "oohwhatwasitagain"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid username" do
    params = %{"username" => "dick", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params, TestAccounts, [identifier: :username])
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    params = %{"email" => "dick@mail.com", "password" => "h4rd2gU3$$"}
    {:error, message} = Login.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "output to current_user does not contain password_hash or otp_secret" do
    params = %{"email" => "fred+1@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, user} = Login.verify(params, TestAccounts)
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

  test "can customize to use different crypto" do
    UserHelper.add_custom_user(@crypto_attrs)
    params = %{"email" => "froderick@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Phauxth.CustomCrypto.verify(params, TestAccounts)
    assert email == "froderick@mail.com"
  end

  test "can customize to use different hash name in the database" do
    UserHelper.add_custom_user(@hashname_attrs)
    params = %{"email" => "froderick@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Phauxth.CustomHashname.verify(params, TestAccounts)
    assert email == "froderick@mail.com"
  end

  test "login fails for invalid email with custom crypto" do
    UserHelper.add_custom_user(@crypto_attrs)
    params = %{"email" => "oranges@mail.com", "password" => "h4rd2gU3$$"}
    {:error, message} = Phauxth.CustomCrypto.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

end
