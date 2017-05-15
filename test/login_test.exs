defmodule Phauxth.LoginTest do
  use Phauxth.TestCase
  use Plug.Test

  alias Phauxth.UserHelper

  @crypto_attrs %{password_hash: "dumb-h4rd2gU3$$-crypto"}
  @hashname_attrs %{encrypted_password: "dumb-h4rd2gU3$$-crypto"}

  setup do
    UserHelper.add_user()
    :ok
  end

  def login(name, password, identifier \\ :email, user_params \\ "email") do
    params = %{user_params => name, "password" => password}
    Phauxth.Login.verify(params, identifier: identifier)
  end

  test "login succeeds with email" do
    {:ok, %{email: email}} = login("fred+1@mail.com", "h4rd2gU3$$")
    assert email == "fred+1@mail.com"
  end

  test "login succeeds with username" do
    {:ok, %{username: username}} = login("fred", "h4rd2gU3$$", :username, "username")
    assert username == "fred"
  end

  test "login fails for incorrect password" do
    {:error, message} = login("fred+1@mail.com", "oohwhatwasitagain")
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid username" do
    {:error, message} = login("dick", "h4rd2gU3$$", :username, "username")
    assert message =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    {:error, message} = login("dick@mail.com", "h4rd2gU3$$")
    assert message =~ "Invalid credentials"
  end

  test "output to current_user does not contain password_hash or otp_secret" do
    {:ok, user} = login("fred+1@mail.com", "h4rd2gU3$$")
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

  test "can customize to use different crypto" do
    UserHelper.add_custom_user(@crypto_attrs)
    params = %{"email" => "froderick@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Phauxth.CustomCrypto.verify(params, identifier: :email)
    assert email == "froderick@mail.com"
  end

  test "can customize to use different hash name in the database" do
    UserHelper.add_custom_user(@hashname_attrs)
    params = %{"email" => "froderick@mail.com", "password" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = Phauxth.CustomHashname.verify(params, identifier: :email)
    assert email == "froderick@mail.com"
  end

  test "login fails for invalid email with custom crypto" do
    UserHelper.add_custom_user(@crypto_attrs)
    params = %{"email" => "oranges@mail.com", "password" => "h4rd2gU3$$"}
    {:error, message} = Phauxth.CustomCrypto.verify(params, identifier: :email)
    assert message =~ "Invalid credentials"
  end

end
