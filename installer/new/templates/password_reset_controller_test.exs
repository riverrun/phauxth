defmodule <%= base %>.Web.PasswordResetControllerTest do
  use <%= base %>.Web.ConnCase

  import <%= base %>.Web.AuthCase

  @valid_attrs %{email: "gladys@mail.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_email %{email: "fred@mail.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_attrs %{email: "gladys@mail.com",  password: "^hEsdg*F899",
    key: "pu9-VNDGe8v9QzO19RLCg3KUNjpxuixg"}
  @invalid_pass %{email: "gladys@mail.com", password: "qwerty",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>.Web.Router, :browser) |> get("/")<% end %>
    add_reset("gladys@mail.com")
    {:ok, %{conn: conn}}
  end

  test "reset password succeeds for correct key", %{conn: conn} do<%= if api do %>
    conn = put(conn, password_reset_path(conn, :update), password_reset: @valid_attrs)
    assert json_response(conn, 200)["info"]["detail"]<% else %>
    conn = put(conn, password_reset_path(conn, :update), password_reset: @valid_attrs)
    assert conn.private.phoenix_flash["info"] =~ "Password reset"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "reset password fails for invalid email", %{conn: conn} do<%= if api do %>
    conn = post(conn, password_reset_path(conn, :create), password_reset: @invalid_email)
    assert json_response(conn, 404)["errors"]["detail"]<% else %>
    conn = post(conn, password_reset_path(conn, :create), password_reset: @invalid_email)
    assert conn.private.phoenix_template == "new.html"<% end %>
  end

  test "reset password fails for incorrect key", %{conn: conn} do<%= if api do %>
    conn = put(conn, password_reset_path(conn, :update), password_reset: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    conn = put(conn, password_reset_path(conn, :update), password_reset: @invalid_attrs)
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"<% end %>
  end

  test "reset password fails for invalid password", %{conn: conn} do<%= if api do %>
    conn = put(conn, password_reset_path(conn, :update), password_reset: @invalid_pass)
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    conn = put(conn, password_reset_path(conn, :update), password_reset: @invalid_pass)
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"<% end %>
  end
end
