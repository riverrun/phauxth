defmodule Phauxth.AuthenticateTest do
  use Phauxth.TestCase
  use Plug.Test

  alias Phauxth.{Authenticate, SessionHelper, UserHelper}

  setup do
    user = UserHelper.add_user()
    {:ok, %{user: user}}
  end

  def call(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn
    |> put_session(:user_id, id)
    |> Authenticate.call([])
  end

  test "current user in session", %{user: user} do
    conn = call(user.id)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

  test "no user found", %{user: user} do
    conn = call(user.id + 1)
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session", %{user: user} do
    conn = call(user.id) |> configure_session(drop: true)
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Authenticate.call([])
    assert newconn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash or otp_secret", %{user: user} do
    conn = call(user.id)
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
