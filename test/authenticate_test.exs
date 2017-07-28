defmodule Phauxth.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, SessionHelper, TestAccounts, Token}

  @max_age 24 * 60 * 60

  defmodule AbsintheAuthenticate do
    use Phauxth.Authenticate.Base
    import Plug.Conn

    def set_user(user, conn) do
      put_private(conn, :absinthe, %{token: %{current_user: user}})
    end
  end

  def call(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn
    |> put_session(:user_id, id)
    |> Authenticate.call({:session, @max_age, TestAccounts})
  end

  def call_api(id, token \\ nil, max_age \\ @max_age) do
    conn = conn(:get, "/") |> SessionHelper.add_key
    put_req_header(conn, "authorization", token || Token.sign(conn, id))
    |> Authenticate.call({:token, max_age, TestAccounts})
  end

  test "current user in session" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call(10)
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call(1) |> configure_session(drop: true)
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Authenticate.call({:session, @max_age, TestAccounts})
    assert newconn.assigns == %{current_user: nil}
  end

  test "authenticate api sets the current_user" do
    conn = call_api(1)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

  test "authenticate api with invalid token sets the current_user to nil" do
    conn = call_api(1, "garbage")
    assert conn.assigns == %{current_user: nil}
  end

  test "log reports error message for invalid token" do
    assert capture_log(fn ->
      call_api(1, "garbage")
    end) =~ ~s(user=nil message="invalid token")
  end

  test "log reports error message for expired token" do
    assert capture_log(fn ->
      call_api(1, nil, -1000)
    end) =~ ~s(user=nil message="expired token")
  end

  test "authenticate api with no token sets the current_user to nil" do
    conn = conn(:get, "/") |> Authenticate.call({:token, @max_age, TestAccounts})
    assert conn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  test "customized set_user" do
    conn = conn(:get, "/") |> SessionHelper.add_key
    conn = put_req_header(conn, "authorization", Token.sign(conn, 1))
           |> AbsintheAuthenticate.call({:token, @max_age, TestAccounts})
    %{token: %{current_user: user}} = conn.private.absinthe
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

end
