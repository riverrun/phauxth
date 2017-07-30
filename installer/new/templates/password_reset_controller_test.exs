defmodule <%= base %>Web.PasswordResetControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, :browser) |> get("/")<% end %>
    add_user("gladys@mail.com")
    {:ok, %{conn: conn}}
  end

  test "reset password succeeds for correct key", %{conn: conn} do
    key = Phauxth.Token.sign(conn, %{"email" => "gladys@mail.com"})
    valid_attrs = %{email: "gladys@mail.com", password: "^hEsdg*F899", key: key}
    conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)<%= if api do %>
    assert json_response(conn, 200)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "password has been reset"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "reset password fails for invalid email", %{conn: conn} do
    key = Phauxth.Token.sign(conn, %{"email" => "fred@mail.com"})
    invalid_email = %{email: "fred@mail.com", password: "^hEsdg*F899", key: key}
    conn = post(conn, password_reset_path(conn, :create), password_reset: invalid_email)<%= if api do %>
    assert json_response(conn, 404)["errors"]["detail"]<% else %>
    assert conn.private.phoenix_template == "new.html"<% end %>
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    key = Phauxth.Token.sign(conn, %{"email" => "gladys@mail.com"}) |> String.downcase
    invalid_attrs = %{email: "gladys@mail.com", password: "^hEsdg*F899", key: key}
    conn = put(conn, password_reset_path(conn, :update), password_reset: invalid_attrs)<%= if api do %>
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"<% end %>
  end

end
