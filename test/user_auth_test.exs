defmodule Phauxth.UserAuthTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{UserAuth, SessionHelper, TestAccounts}

  @session_opts {{nil, TestAccounts, []}, []}

  defp call(id, session_opts \\ @session_opts) do
    SessionHelper.add_session(id, :user_id)
    |> UserAuth.call(session_opts)
  end

  test "current user in session" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call(11)
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call(1) |> delete_session(:user_id)

    newconn =
      conn(:get, "/")
      |> recycle_cookies(conn)
      |> SessionHelper.sign_conn()
      |> UserAuth.call(@session_opts)

    assert newconn.assigns == %{current_user: nil}
  end

  test "user_id can be uuid" do
    uuid = "4a43f849-d9fa-439e-b887-735378009c95"
    conn = call(uuid)
    %{current_user: user} = conn.assigns
    assert user.email == "brian@example.com"
    assert user.role == "user"
  end
end
