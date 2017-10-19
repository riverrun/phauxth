defmodule <%= base %>Web.UserControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthCase
  alias <%= base %>.Accounts

  @create_attrs %{email: "bill@example.com", password: "hard2guess"}
  @update_attrs %{email: "william@example.com"}
  @invalid_attrs %{email: nil}

  setup %{conn: conn} = config do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, [:browser]) |> get("/")<% end %>
    if email = config[:login] do
      user = add_user(email)
      other = add_user("tony@example.com")<%= if api do %>
      conn = conn |> add_token_conn(user)<% else %>
      conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")<% end %>
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  @tag login: "reg@example.com"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)<%= if api do %>
    assert json_response(conn, 200)<% else %>
    assert html_response(conn, 200) =~ "Listing Users"<% end %>
  end

  test "renders /users error for unauthorized user", %{conn: conn}  do
    conn = get conn, user_path(conn, :index)<%= if api do %>
    assert json_response(conn, 401)<% else %>
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end<%= if not api do %>

  test "renders form for new users", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New User"
  end<% end %>

  @tag login: "reg@example.com"
  test "show chosen user's page", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :show, user)<%= if api do %>
    assert json_response(conn, 200)["data"] == %{"id" => user.id, "email" => "reg@example.com"}<% else %>
    assert html_response(conn, 200) =~ "Show User"<% end %>
  end

  test "creates user when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_attrs<%= if api do %>
    assert json_response(conn, 201)["data"]["id"]
    assert Accounts.get_by(%{"email" => "bill@example.com"})<% else %>
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs<%= if api do %>
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    assert html_response(conn, 200) =~ "New User"<% end %>
  end<%= if not api do %>

  @tag login: "reg@example.com"
  test "renders form for editing chosen user", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit User"
  end<% end %>

  @tag login: "reg@example.com"
  test "updates chosen user when data is valid", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @update_attrs<%= if api do %>
    assert json_response(conn, 200)["data"]["id"] == user.id<% else %>
    assert redirected_to(conn) == user_path(conn, :show, user)<% end %>
    updated_user = Accounts.get(user.id)
    assert updated_user.email == "william@example.com"<%= if not api do %>
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "william@example.com"<% end %>
  end

  @tag login: "reg@example.com"
  test "does not update chosen user and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs<%= if api do %>
    assert json_response(conn, 422)["errors"] != %{}<% else %>
    assert html_response(conn, 200) =~ "Edit User"<% end %>
  end

  @tag login: "reg@example.com"
  test "deletes chosen user", %{conn: conn, user: user} do
    conn = delete conn, user_path(conn, :delete, user)<%= if api do %>
    assert response(conn, 204)<% else %>
    assert redirected_to(conn) == session_path(conn, :new)<% end %>
    refute Accounts.get(user.id)
  end

  @tag login: "reg@example.com"
  test "cannot delete other user", %{conn: conn, other: other} do
    conn = delete conn, user_path(conn, :delete, other)<%= if api do %>
    assert json_response(conn, 403)["errors"]["detail"] =~ "not authorized"<% else %>
    assert redirected_to(conn) == user_path(conn, :index)<% end %>
    assert Accounts.get(other.id)
  end
end
