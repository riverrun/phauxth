defmodule <%= base %>Web.PasswordResetControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, :browser) |> get("/")<% end %>
    add_reset_user("gladys@mail.com")
    {:ok, %{conn: conn}}
  end

  test "user can create a password reset request", %{conn: conn} do
    valid_attrs = %{email: "gladys@mail.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: valid_attrs)<%= if api do %>
    assert json_response(conn, 201)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "your inbox for instructions"
    assert redirected_to(conn) == user_path(conn, :index)<% end %>
  end

  test "create function fails for no user", %{conn: conn} do
    invalid_attrs = %{email: "prettylady@mail.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: invalid_attrs)<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"]<% else %>
    assert assert html_response(conn, 200) =~ "Reset Password"<% end %>
  end

  test "reset password succeeds for correct key", %{conn: conn} do
    valid_attrs = %{email: "gladys@mail.com", password: "^hEsdg*F899", key: gen_key("gladys@mail.com")}
    conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)<%= if api do %>
    assert json_response(conn, 200)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "password has been reset"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    invalid_attrs = %{email: "gladys@mail.com", password: "^hEsdg*F899", key: "garbage"}
    conn = put(conn, password_reset_path(conn, :update), password_reset: invalid_attrs)<%= if api do %>
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"<% end %>
  end

end
