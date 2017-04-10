defmodule Phauxth.AuthorizeTest do
  use ExUnit.Case
  use Plug.Test

  import Phauxth.AccessControl

  @admin %{id: 2, username: "Big Boss", role: "admin"}
  @user %{id: 1, username: "Raymond Luxury Yacht", role: "user"}

  def call(path, current_user, roles) do
    conn(:get, path)
    |> assign(:current_user, current_user)
    |> authorize_role(roles: roles)
  end

  def call_id(conn, id, user) do
    %{conn | params: %{"id" => id}}
    |> assign(:current_user, user)
    |> authorize_id([])
  end

  test "correct token with role admin" do
    conn = call("/admin", @admin, ["admin"]) |> send_resp(200, "")
    refute conn.private[:phauxth_error]
    assert conn.status == 200
  end

  test "correct token with role user" do
    conn = call("/users", @user, ["user"]) |> send_resp(200, "")
    refute conn.private[:phauxth_error]
    assert conn.status == 200
  end

  test "no user error" do
    conn = call("/admin", nil, ["admin"])
    assert conn.private.phauxth_error =~ "You have to be logged in to view"
  end

  test "insufficient permissions" do
    conn = call("/admin", @admin, ["user"])
    assert conn.private.phauxth_error =~ "You do not have permission to view"
  end

  test "user with correct id can access page" do
    path = "/users/1/edit"
    conn = conn(:get, path) |> call_id("1", @user) |> send_resp(200, "")
    refute conn.private[:phauxth_error]
    assert conn.status == 200
  end

  test "user with wrong id cannot access resource" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call_id("10", @user)
    assert conn.private.phauxth_error =~ "You do not have permission to view"
  end
end
