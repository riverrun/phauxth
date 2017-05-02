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

  def login(name, password, uniq \\ :email, user_params \\ "email") do
    conn(:post, "/login",
         %{"session" => %{user_params => name, "password" => password}})
    |> Phauxth.Login.call({uniq, user_params})
  end

  test "init function" do
    assert Phauxth.Login.init([]) == {:email, "email"}
  end

  test "login succeeds with email" do
    conn = login("fred+1@mail.com", "h4rd2gU3$$")
    %{email: email} = conn.private[:phauxth_user]
    assert email == "fred+1@mail.com"
  end

  test "login succeeds with username" do
    conn = login("fred", "h4rd2gU3$$", :username, "username")
    %{username: username} = conn.private[:phauxth_user]
    assert username == "fred"
  end

  test "login fails for incorrect password" do
    conn = login("fred+1@mail.com", "oohwhatwasitagain")
    assert conn.private[:phauxth_error] =~ "Invalid credentials"
  end

  test "login fails for invalid username" do
    conn = login("dick", "h4rd2gU3$$", :username, "username")
    assert conn.private[:phauxth_error] =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    conn = login("dick@mail.com", "h4rd2gU3$$")
    assert conn.private[:phauxth_error] =~ "Invalid credentials"
  end

  test "output to current_user does not contain password_hash or otp_secret" do
    conn = login("fred+1@mail.com", "h4rd2gU3$$")
    user = conn.private[:phauxth_user]
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

  test "can customize to use different crypto" do
    UserHelper.add_custom_user(@crypto_attrs)
    conn = conn(:post, "/login", %{"session" =>
                  %{"email" => "froderick@mail.com", "password" => "h4rd2gU3$$"}})
    |> Phauxth.CustomCrypto.call({:email, "email"})
    %{email: email} = conn.private[:phauxth_user]
    assert email == "froderick@mail.com"
  end

  test "can customize to use different hash name in the database" do
    UserHelper.add_custom_user(@hashname_attrs)
    conn = conn(:post, "/login", %{"session" =>
                  %{"email" => "froderick@mail.com", "password" => "h4rd2gU3$$"}})
    |> Phauxth.CustomHashname.call({:email, "email"})
    %{email: email} = conn.private[:phauxth_user]
    assert email == "froderick@mail.com"
  end

  test "custom login error message" do
    UserHelper.add_custom_user(@hashname_attrs)
    conn = conn(:post, "/login", %{"session" =>
                  %{"email" => "froderick@mail.com", "password" => "password"}})
    |> Phauxth.CustomHashname.call({:email, "email"})
    assert conn.private[:phauxth_error] =~ "Oh no you don't"
  end

  test "login fails for invalid email with custom crypto" do
    UserHelper.add_custom_user(@crypto_attrs)
    conn = conn(:post, "/login", %{"session" =>
                  %{"email" => "oranges@mail.com", "password" => "h4rd2gU3$$"}})
    |> Phauxth.CustomCrypto.call({:email, "email"})
    assert conn.private[:phauxth_error] =~ "Invalid credentials"
  end

end
