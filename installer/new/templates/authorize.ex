defmodule <%= base %>Web.Authorize do

  import Plug.Conn
  import Phoenix.Controller<%= if not api do %>
  import <%= base %>Web.Router.Helpers<% end %>

  # This function can be used to customize the `action` function in
  # the controller so that only authenticated users can access each route.
  # See the [Authorization wiki page](https://github.com/riverrun/phauxth/wiki/Authorization)
  # for more information and examples.
  def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error(conn, "You need to log in to view this page", session_path(conn, :new))<% end %>
  end
  def auth_action(%Plug.Conn{assigns: %{current_user: current_user},
      params: params} = conn, module) do
    apply(module, action_name(conn), [conn, params, current_user])
  end

  # Plug to only allow authenticated users to access the resource.
  # See the user controller for an example.
  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error(conn, "You need to log in to view this page", session_path(conn, :new))<% end %>
  end
  def user_check(conn, _opts), do: conn

  # Plug to only allow unauthenticated users to access the resource.
  # See the session controller for an example.
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn
  def guest_check(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts) do<%= if api do %>
    put_status(conn, :unauthorized)
    |> render(<%= base %>Web.AuthView, "logged_in.json", [])
    |> halt<% else %>
    error(conn, "You need to log out to view this page", page_path(conn, :index))<% end %>
  end

  # Plug to only allow authenticated users with the correct id to access the resource.
  # See the user controller for an example.
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error(conn, "You need to log in to view this page", session_path(conn, :new))<% end %>
  end
  def id_check(%Plug.Conn{params: %{"id" => id},
      assigns: %{current_user: current_user}} = conn, _opts) do
    id == to_string(current_user.id) and conn ||<%= if api do %>
      error(conn, :forbidden, 403)<% else %>
      error(conn, "You are not authorized to view this page", user_path(conn, :index))<% end %>
  end

  def success(conn, message, path) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: path)
  end<%= if api do %>

  def error(conn, status, code) do
    put_status(conn, status)
    |> render(<%= base %>Web.AuthView, "#{code}.json", [])
    |> halt
  end<% else %>

  def error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
    |> halt
  end<% end %>
end
