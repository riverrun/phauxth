defmodule Phauxth.Authenticate.BaseTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, CustomAuthenticate, CustomCall, SessionHelper, TestUsers}

  @session_opts %{user_context: TestUsers, log_meta: [], opts: []}

  defp call(id, opts \\ @session_opts) do
    id |> SessionHelper.add_session() |> Authenticate.call(opts)
  end

  defp custom_authenticate(id) do
    id |> SessionHelper.add_session(:user_id) |> CustomAuthenticate.call(@session_opts)
  end

  defp custom_call(id) do
    id |> SessionHelper.add_session() |> CustomCall.call(@session_opts)
  end

  test "current user in session" do
    conn = call("1111")
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call("9999")
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call("1111") |> delete_session(:session_id)

    newconn =
      conn(:get, "/")
      |> recycle_cookies(conn)
      |> SessionHelper.sign_conn()
      |> Authenticate.call(@session_opts)

    assert newconn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash" do
    conn = call("1111")
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  test "current user in session - using user_id" do
    conn = custom_authenticate("1")
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "user_id can be uuid" do
    uuid = "4a43f849-d9fa-439e-b887-735378009c95"
    conn = custom_authenticate(uuid)
    %{current_user: user} = conn.assigns
    assert user.email == "brian@example.com"
    assert user.role == "user"
  end

  test "custom call" do
    assert capture_log(fn ->
             custom_call("1111")
           end) =~ ~s(user=1 message="user authenticated" path=/)
  end
end
