defmodule <%= base %>.Web.SessionController do
  use <%= base %>.Web, :controller

  import <%= base %>.Web.Authorize

  plug Phauxth.Login when action in [:create]<%= if api do %>

  def create(%Plug.Conn{private: %{phauxth_error: _message}} = conn, _) do
    error(conn, :unauthorized, 401)<% else %>

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(%Plug.Conn{private: %{phauxth_error: message}} = conn, _) do
    error(conn, message, session_path(conn, :new))<% end %>
  end
  def create(%Plug.Conn{private: %{phauxth_user: %{id: id}}} = conn, _) do<%= if api do %>
    token = Phoenix.Token.sign(<%= base %>.Web.Endpoint, "user auth", id)
    render(conn, <%= base %>.Web.SessionView, "info.json", %{info: token})<% else %>
    put_session(conn, :user_id, id)
    |> success("You have been logged in", user_path(conn, :index))
  end

  def delete(conn, _) do
    configure_session(conn, drop: true)
    |> success("You have been logged out", page_path(conn, :index))<% end %>
  end
end
