defmodule <%= base %>Web.SessionControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase<%= if not api do %>
  alias <%= base %>.Accounts<% end %>

  @create_attrs %{email: "robin@example.com", password: "reallyHard2gue$$"}
  @invalid_attrs %{email: "robin@example.com", password: "cannotGue$$it"}<%= if confirm do %>
  @unconfirmed_attrs %{email: "lancelot@example.com", password: "reallyHard2gue$$"}<% end %><%= if remember do %>
  @rem_attrs %{email: "robin@example.com", password: "reallyHard2gue$$", remember_me: "true"}
  @no_rem_attrs Map.merge(@rem_attrs, %{remember_me: "false"})<% end %>

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, [:browser]) |> get("/")<% end %><%= if confirm do %>
    add_user("lancelot@example.com")
    user = add_user_confirmed("robin@example.com")<% else %>
    user = add_user("robin@example.com")<% end %>
    {:ok, %{conn: conn, user: user}}
  end<%= if not api do %>

  test "rendering login form fails for user that is already logged in", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = get conn, session_path(conn, :new)
    assert redirected_to(conn) == page_path(conn, :index)
  end<% end %>

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

  test "login fails for user that is already logged in", %{conn: conn, user: user} do<%= if api do %>
    conn = conn |> add_token_conn(user)
    conn = post conn, session_path(conn, :create), session: @create_attrs
    assert json_response(conn, 401)["errors"]["detail"] =~ "already logged in"
  end<% else %>
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = post conn, session_path(conn, :create), session: @create_attrs
    assert redirected_to(conn) == page_path(conn, :index)
  end<% end %>

  test "login fails for invalid password", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end<% else %>
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "logout succeeds and session is deleted", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = delete conn, session_path(conn, :delete, user)
    assert redirected_to(conn) == page_path(conn, :index)
    conn = get conn, user_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
    assert Accounts.list_sessions(user.id) == %{}
  end<%= if remember do %>

  test "remember me cookie is added / not added", %{conn: conn} do
    rem_conn = post conn, session_path(conn, :create), session: @rem_attrs
    assert rem_conn.resp_cookies["remember_me"]
    no_rem_conn = post conn, session_path(conn, :create), session: @no_rem_attrs
    refute no_rem_conn.resp_cookies["remember_me"]
  end<% end %><% end %>
end
