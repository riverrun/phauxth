defmodule Phauxth.RememberTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, Remember, SessionHelper}

  @max_age 7 * 24 * 60 * 60

  setup do
    conn =
      conn(:get, "/")
      |> SessionHelper.sign_conn()
      |> Remember.add_rem_cookie("1")

    {:ok, %{conn: conn}}
  end

  test "init function" do
    assert {_, {Phauxth.TestUsers, [], _}} = Remember.init(create_session_func: &create_session/1)
  end

  test "init function raises if no create_session_func is set" do
    assert_raise RuntimeError, fn -> Remember.init([]) end
  end

  test "init function raises if create_session_func is wrong arity" do
    assert_raise RuntimeError, fn ->
      Remember.init(create_session_func: &wrong_create_session/0)
    end
  end

  test "current_user set when calling remember with default options", %{conn: conn} do
    conn =
      conn
      |> SessionHelper.recycle_and_sign()
      |> Remember.call(opts())

    %{current_user: user} = conn.assigns
    assert user.username == "fred"
    assert user.role == "user"
  end

  test "session added when calling remember", %{conn: conn} do
    session_id =
      conn
      |> SessionHelper.recycle_and_sign()
      |> Remember.call(opts())
      |> get_session(:phauxth_session_id)

    assert session_id
  end

  test "error log when the token is invalid", %{conn: conn} do
    invalid = "garbage"
    conn = put_resp_cookie(conn, "remember_me", invalid, http_only: true, max_age: @max_age)

    assert capture_log(fn ->
             conn(:get, "/")
             |> recycle_cookies(conn)
             |> SessionHelper.sign_conn()
             |> Remember.call(opts())
           end) =~ ~s(user=nil message=invalid)
  end

  test "call remember with no remember cookie" do
    conn =
      conn(:get, "/")
      |> SessionHelper.sign_conn()
      |> Remember.call(opts())

    refute conn.assigns[:current_user]
  end

  test "call remember with current_user already set", %{conn: conn} do
    conn =
      conn
      |> SessionHelper.recycle_and_sign()
      |> put_session(:phauxth_session_id, "5555")
      |> Authenticate.call({Phauxth.TestUsers, [], []})
      |> Remember.call(opts())

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
      conn
      |> Remember.delete_rem_cookie()
      |> send_resp(200, "")

    refute conn.req_cookies["remember_me"]
  end

  test "output to current_user does not contain password_hash", %{conn: conn} do
    conn =
      conn
      |> SessionHelper.recycle_and_sign()
      |> Remember.call(opts())

    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  defp create_session(conn) do
    %{id: user_id} = conn.assigns.current_user
    Phauxth.TestUsers.create_session(%{user_id: user_id})
  end

  defp wrong_create_session, do: IO.puts("No!")

  defp opts, do: Remember.init(create_session_func: &create_session/1)
end
