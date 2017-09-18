defmodule <%= base %>Web.ConfirmControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>.Router, :browser) |> get("/")<% end %>
    add_user("arthur@example.com")
    {:ok, %{conn: conn}}
  end

  test "confirmation succeeds for correct key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("arthur@example.com")))<%= if api do %>
    assert json_response(conn, 200)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "account has been confirmed"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: "garbage"))<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"]<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "confirmation fails for incorrect email", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("gerald@example.com")))<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"]<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

end
