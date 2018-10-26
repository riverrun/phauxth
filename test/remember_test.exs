defmodule Phauxth.RememberTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, Remember, SessionHelper, TestUsers}

  @max_age 7 * 24 * 60 * 60
  @opts %{user_context: TestUsers, log_meta: [], opts: []}

  setup do
    conn =
      conn(:get, "/")
      |> SessionHelper.sign_conn()
      |> Remember.add_rem_cookie("1")

    {:ok, %{conn: conn}}
  end

  test "init function" do
    assert Remember.init([]) == %{user_context: TestUsers, log_meta: [], opts: []}
  end

  test "call remember with default options", %{conn: conn} do
    conn =
      conn
      |> SessionHelper.recycle_and_sign()
      |> Remember.call(@opts)

    %{current_user: user} = conn.assigns
    assert user.username == "fred"
    assert user.role == "user"
  end

  test "error log when the cookie is invalid", %{conn: conn} do
    invalid =
      "SFMyNTY.g3QAAAACZAAEZGF0YWeBZAAGc2lnbmVkbgYAHU1We1sB.mMbd1DOs-1UnE29sTg1O9QC_l1YAHURVe7FsTTsXj88"

    conn = put_resp_cookie(conn, "remember_me", invalid, http_only: true, max_age: @max_age)

    assert capture_log(fn ->
             conn(:get, "/")
             |> recycle_cookies(conn)
             |> SessionHelper.sign_conn()
             |> Remember.call(@opts)
           end) =~ ~s(user=nil message=invalid)
  end

  test "call remember with no remember cookie" do
    conn =
      conn(:get, "/")
      |> SessionHelper.sign_conn()
      |> Remember.call(@opts)

    refute conn.assigns[:current_user]
  end

  test "call remember with current_user already set", %{conn: conn} do
    conn =
      conn
      |> SessionHelper.recycle_and_sign()
      |> put_session(:session_id, "5555")
      |> Authenticate.call(%{user_context: TestUsers, log_meta: [], opts: []})
      |> Remember.call(@opts)

    %{current_user: user} = conn.assigns
    assert user.id == "4a43f849-d9fa-439e-b887-735378009c95"
    assert user.email == "brian@example.com"
  end

  test "add cookie", %{conn: conn} do
    conn = SessionHelper.recycle_and_sign(conn)
    assert conn.req_cookies["remember_me"]
  end

  test "delete cookie", %{conn: conn} do
    conn =
      Remember.delete_rem_cookie(conn)
      |> send_resp(200, "")

    refute conn.req_cookies["remember_me"]
  end

  test "output to current_user does not contain password_hash", %{conn: conn} do
    conn =
      SessionHelper.recycle_and_sign(conn)
      |> Remember.call(@opts)

    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end
end
