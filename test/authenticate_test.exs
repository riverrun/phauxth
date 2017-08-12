defmodule Phauxth.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, SessionHelper, TestAccounts, Token}

  @max_age 4 * 60 * 60
  @session_opts {:session, @max_age, TestAccounts}
  @token_opts {:token, @max_age, TestAccounts}

  def add_session(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn
    |> put_session(:user_id, id)
  end

  def call(id) do
    add_session(id)
    |> Authenticate.call({@session_opts, []})
  end

  def add_token(id, token \\ nil) do
    conn = conn(:get, "/") |> SessionHelper.add_key
    put_req_header(conn, "authorization", token || Token.sign(conn, id))
  end

  def call_api(id, token \\ nil, max_age \\ @max_age) do
    opts = {:token, max_age, TestAccounts}
    add_token(id, token)
    |> Authenticate.call({opts, []})
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
              |> Authenticate.call({@session_opts, []})
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
    conn = conn(:get, "/") |> Authenticate.call({@token_opts, []})
    assert conn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  test "customized set_user - absinthe example" do
    conn = add_token(1) |> Phauxth.AbsintheAuthenticate.call({@token_opts, []})
    %{token: %{current_user: user}} = conn.private.absinthe
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

  test "customized check_session - checks shoe size before authenticating" do
    conn = add_session(1)
           |> put_session(:shoe_size, 6)
           |> Phauxth.CustomSession.call({@session_opts, []})
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@mail.com"
    conn = add_session(1)
           |> put_session(:shoe_size, 5)
           |> Phauxth.CustomSession.call({@session_opts, []})
    assert conn.assigns == %{current_user: nil}
  end

  test "customized check_token" do
    conn = add_token(1) |> Phauxth.CustomToken.call({@token_opts, []})
    %{current_user: user} = conn.assigns
    assert user.email == "froderick@mail.com"
  end

end
