defmodule <%= base %>.Web.ConfirmControllerTest do
  use <%= base %>.Web.ConnCase

  import <%= base %>.Web.AuthCase

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>.Router, :browser) |> get("/")<% end %>
    add_user("arthur@mail.com")

    {:ok, %{conn: conn}}
  end

  test "confirmation succeeds for correct key", %{conn: conn} do
    email = "arthur@mail.com"
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    conn = get(conn, confirm_path(conn, :new, email: email, key: key))<%= if api do %>
    assert json_response(conn, 200)["info"]["detail"]<% else %>
    assert conn.private.phoenix_flash["info"] =~ "account has been confirmed"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    email = "arthur@mail.com"
    key = "pu9-VNdgE8V9QzO19RLCG3KUNjpxuixg"
    conn = get(conn, confirm_path(conn, :new, email: email, key: key))<%= if api do %>
    assert json_response(conn, 404)["errors"]["detail"]<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "confirmation fails for incorrect email", %{conn: conn} do
    email = "gerald@mail.com"
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    conn = get(conn, confirm_path(conn, :new, email: email, key: key))<%= if api do %>
    assert json_response(conn, 404)["errors"]["detail"]<% else %>
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end
end
