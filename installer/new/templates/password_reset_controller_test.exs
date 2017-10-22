defmodule <%= base %>Web.PasswordResetControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase<%= if not api do %>
  alias <%= base %>.Accounts<% end %>

  @update_attrs %{email: "gladys@example.com", password: "^hEsdg*F899"}

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, :browser) |> get("/")<% end %>
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end<%= if not api do %>

  defp get_user do
    Accounts.get_by(%{"email" => "gladys@example.com"})
  end<% end %>

  test "user can create a password reset request", %{conn: conn} do
    valid_attrs = %{email: "gladys@example.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: valid_attrs)<%= if api do %>
    assert json_response(conn, 201)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "sessions are deleted when user creates a password reset request", %{conn: conn, user: user} do
    valid_attrs = %{email: "gladys@example.com"}
    add_phauxth_session(conn, user)
    assert get_user().sessions != %{}
    post(conn, password_reset_path(conn, :create), password_reset: valid_attrs)
    assert get_user().sessions == %{}<% end %>
  end

  test "create function fails for no user", %{conn: conn} do
    invalid_attrs = %{email: "prettylady@example.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: invalid_attrs)<%= if api do %>
    assert json_response(conn, 201)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
    assert redirected_to(conn) == page_path(conn, :index)<% end %>
  end

  test "reset password succeeds for correct key", %{conn: conn} do
    valid_attrs = Map.put(@update_attrs, :key, gen_key("gladys@example.com"))
    reset_conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)<%= if api do %>
    assert json_response(reset_conn, 200)["info"]["detail"] =~ "password has been reset"<% else %>
    assert reset_conn.private.phoenix_flash["info"] =~ "password has been reset"
    assert redirected_to(reset_conn) == session_path(conn, :new)<% end %>
    conn = post conn, session_path(conn, :create), session: @update_attrs<%= if api do %>
    assert json_response(conn, 200)["access_token"]<% else %>
    assert redirected_to(conn) == user_path(conn, :index)<% end %>
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    invalid_attrs = %{email: "gladys@example.com", password: "^hEsdg*F899", key: "garbage"}
    conn = put(conn, password_reset_path(conn, :update), password_reset: invalid_attrs)<%= if api do %>
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"<% end %>
  end
end
