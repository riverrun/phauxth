defmodule <%= base %>.Web.Authorize do

  import Plug.Conn
  import Phoenix.Controller<%= if not api do %>
  import <%= base %>.Web.Router.Helpers<% end %>

  def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error conn, "You need to log in to view this page", session_path(conn, :new)<% end %>
  end
  def auth_action(%Plug.Conn{assigns: %{current_user: current_user},
    params: params} = conn, module) do
    apply(module, action_name(conn), [conn, params, current_user])
  end

  def auth_action_id(%Plug.Conn{params: %{"user_id" => user_id} = params,
    assigns: %{current_user: %{id: id} = current_user}} = conn, module) do
    if user_id == to_string(id) do
      apply(module, action_name(conn), [conn, params, current_user])
    else<%= if api do %>
      error(conn, :forbidden, 403)<% else %>
      error conn, "You are not authorized to view this page", user_path(conn, :index)<% end %>
    end
  end
  def auth_action_id(conn, _), do: error(conn, :unauthorized, 401)

  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error conn, "You need to log in to view this page", session_path(conn, :new)<% end %>
  end
  def user_check(conn, _opts), do: conn

  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error conn, "You need to log in to view this page", session_path(conn, :new)<% end %>
  end
  def id_check(%Plug.Conn{params: %{"id" => id},
      assigns: %{current_user: current_user}} = conn, _opts) do
    if id == to_string(current_user.id) do
      conn
    else<%= if api do %>
      error(conn, :forbidden, 403)<% else %>
      error conn, "You are not authorized to view this page", user_path(conn, :index)<% end %>
    end
  end

  def success(conn, message, path) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: path)
  end<%= if api do %>

  def error(conn, status, code) do
    put_status(conn, status)
    |> render(<%= base %>.Web.AuthView, "#{code}.json", [])
    |> halt
  end<% else %>

  def error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
    |> halt
  end<% end %>
end
