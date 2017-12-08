defmodule Phauxth.SessionAuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Authenticate, SessionHelper, TestAccounts}

  @max_age 4 * 60 * 60
  @session_opts {:session, @max_age, TestAccounts, []}

  defp add_session(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn()
    |> put_session(:phauxth_session_id, id)
  end

  defp call(id, session_opts \\ @session_opts) do
    add_session(id)
    |> Authenticate.call({session_opts, []})
  end

  test "current user in session" do
    conn = call("F25/1mZuBno+Pfu061")
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call("F25/1mZuBno+Pfu0610")
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call("F25/1mZuBno+Pfu061") |> delete_session(:phauxth_session_id)

    newconn =
      conn(:get, "/")
      |> recycle_cookies(conn)
      |> SessionHelper.sign_conn()
      |> Authenticate.call({@session_opts, []})

    assert newconn.assigns == %{current_user: nil}
  end

  test "user not authenticated if session id not in db" do
    conn = call("F25/1mZUBno+Pfu061")
    assert conn.assigns == %{current_user: nil}
  end

  test "user not authenticated if session has expired" do
    conn = call("F25/1mZuBno+Pfu061", {:session, 0, TestAccounts, []})
    assert conn.assigns == %{current_user: nil}
  end

  test "user_id can be uuid" do
    uuid = "4a43f849-d9fa-439e-b887-735378009c95"
    conn = call("FQcPdSYY9HlaRUKCc" <> uuid)
    %{current_user: user} = conn.assigns
    assert user.email == "brian@example.com"
    assert user.role == "user"
  end

  test "output to current_user does not contain password_hash" do
    conn = call("F25/1mZuBno+Pfu061")
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  test "customized check_session - with custom session id" do
    conn =
      add_session("Fc0k6ku4lm61uO7pnBKreWoHo1")
      |> Phauxth.CustomSession.call({@session_opts, []})

    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
  end

  test "fresh_session? can determine if session is fresh or not" do
    conn = call("F25/1mZuBno+Pfu061")
    assert Authenticate.fresh_session?(conn) == true
    conn = call("S25/1mZuBno+Pfu061")
    assert Authenticate.fresh_session?(conn) == false
    conn = call(nil)
    assert Authenticate.fresh_session?(conn) == false
  end
end
