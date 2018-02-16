defmodule Phauxth.SessionAuthTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{CustomSessionAuth, SessionAuth, SessionHelper, TestAccounts}

  @max_age 4 * 60 * 60
  @session_opts {{@max_age, TestAccounts, []}, []}

  defp call(id, opts \\ @session_opts) do
    SessionHelper.add_session(id)
    |> SessionAuth.call(opts)
  end

  defp custom_call(id) do
    SessionHelper.add_session(id, :user_id)
    |> CustomSessionAuth.call(@session_opts)
  end

  test "current user in session" do
    conn = call("F25/1mZuBno+Pfu06")
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call("Finvalid")
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call("F25/1mZuBno+Pfu06") |> delete_session(:session_id)

    newconn =
      conn(:get, "/")
      |> recycle_cookies(conn)
      |> SessionHelper.sign_conn()
      |> SessionAuth.call(@session_opts)

    assert newconn.assigns == %{current_user: nil}
  end

  test "user not authenticated if session id not in db" do
    conn = call("F25/1mZUBno+Pfu06")
    assert conn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash" do
    conn = call("F25/1mZuBno+Pfu06")
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  test "current user in session - using user_id" do
    conn = custom_call(1)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "user_id can be uuid" do
    uuid = "4a43f849-d9fa-439e-b887-735378009c95"
    conn = custom_call(uuid)
    %{current_user: user} = conn.assigns
    assert user.email == "brian@example.com"
    assert user.role == "user"
  end
end
