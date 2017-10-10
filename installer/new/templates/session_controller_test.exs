defmodule <%= base %>Web.SessionControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase

  @create_attrs %{email: "robin@example.com", password: "reallyHard2gue$$"}
  @invalid_attrs %{email: "robin@example.com", password: "cannotGue$$it"}<%= if confirm do %>
  @unconfirmed_attrs %{email: "lancelot@example.com", password: "reallyHard2gue$$"}
  @rem_attrs %{email: "robin@example.com", password: "reallyHard2gue$$", remember_me: true}<% end %>

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, [:browser]) |> get("/")<% end %><%= if confirm do %>
    add_user("lancelot@example.com")
    user = add_user_confirmed("robin@example.com")<% else %>
    user = add_user("robin@example.com")<% end %>
    {:ok, %{conn: conn, user: user}}
  end

  test "login succeeds", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @create_attrs<%= if api do %>
    assert json_response(conn, 200)["access_token"]<% else %>
    assert redirected_to(conn) == user_path(conn, :index)<% end %>
  end<%= if confirm do %>

  test "login fails for user that is not yet confirmed", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @unconfirmed_attrs<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end<% else %>
    assert redirected_to(conn) == session_path(conn, :new)
  end<% end %><% end %>

  test "login fails for invalid password", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end<% else %>
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "logout succeeds", %{conn: conn, user: user} do
    conn = conn |> put_session(:user_id, user.id) |> send_resp(:ok, "/")
    conn = delete conn, session_path(conn, :delete, user)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "remember me cookie is added / not added", %{conn: conn} do
    rem_conn = post conn, session_path(conn, :create), session: @rem_attrs
    assert rem_conn.resp_cookies["remember_me"]
    no_rem_conn = post conn, session_path(conn, :create), session: Map.merge(@rem_attrs, %{remember_me: false})
    refute no_rem_conn.resp_cookies["remember_me"]
  end<% end %>
end
