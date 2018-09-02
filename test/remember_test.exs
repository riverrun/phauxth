defmodule Phauxth.RememberTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, Remember, SessionHelper, TestAccounts}

  @max_age 7 * 24 * 60 * 60
  @opts {@max_age, TestAccounts, []}

  setup do
    conn =
      conn(:get, "/")
      |> SessionHelper.sign_conn()
      |> Remember.add_rem_cookie(1)

    {:ok, %{conn: conn}}
  end

  test "init function" do
    assert Remember.init([]) == {{604_800, TestAccounts, []}, []}
    assert Remember.init(max_age: 100) == {{100, TestAccounts, [max_age: 100]}, []}
  end

  test "call remember with default options", %{conn: conn} do
    conn =
      SessionHelper.recycle_and_sign(conn)
      |> Remember.call({@opts, []})

    %{current_user: user} = conn.assigns
    assert user.username == "fred"
    assert user.role == "user"

    <<"S", _session_id::binary-size(16), user_id::binary>> =
      get_session(conn, :phauxth_session_id)

    assert user_id == "1"
  end

  test "error log when the cookie is invalid", %{conn: conn} do
    invalid =
      "SFMyNTY.g3QAAAACZAAEZGF0YWeBZAAGc2lnbmVkbgYAHU1We1sB.mMbd1DOs-1UnE29sTg1O9QC_l1YAHURVe7FsTTsXj88"

    conn = put_resp_cookie(conn, "remember_me", invalid, http_only: true, max_age: 604_800)

    assert capture_log(fn ->
             conn(:get, "/")
             |> recycle_cookies(conn)
             |> SessionHelper.sign_conn()
             |> Remember.call({@opts, []})
           end) =~ ~s(user=nil message="invalid token")
  end

  test "call remember with no remember cookie" do
    conn =
      conn(:get, "/")
      |> SessionHelper.sign_conn()
      |> Remember.call({@opts, []})

    refute conn.assigns[:current_user]
  end

  test "call remember with current_user already set", %{conn: conn} do
    conn =
      SessionHelper.recycle_and_sign(conn)
      |> put_session(:phauxth_session_id, "FQcPdSYY9HlaRUKCc4")
      |> Authenticate.call({{:session, @max_age, TestAccounts, []}, []})
      |> Remember.call({@opts, []})

    %{current_user: user} = conn.assigns
    assert user.id == 4
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
      |> Remember.call({@opts, []})

    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end
end
