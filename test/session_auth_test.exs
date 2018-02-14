defmodule Phauxth.SessionAuthTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{SessionAuth, SessionHelper, TestAccounts}

  @max_age 4 * 60 * 60
  @session_opts {{@max_age, TestAccounts, []}, []}

  defp call(id, session_opts \\ @session_opts) do
    SessionHelper.add_session(id)
    |> SessionAuth.call(session_opts)
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
      |> SessionAuth.call(@session_opts)

    assert newconn.assigns == %{current_user: nil}
  end

  test "user not authenticated if session id not in db" do
    conn = call("F25/1mZUBno+Pfu061")
    assert conn.assigns == %{current_user: nil}
  end

  test "user not authenticated if session has expired" do
    conn = call("F25/1mZuBno+Pfu061", {{0, TestAccounts, []}, []})
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
end
