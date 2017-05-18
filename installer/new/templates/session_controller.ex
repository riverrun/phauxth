defmodule <%= base %>.Web.SessionController do
  use <%= base %>.Web, :controller

  import <%= base %>.Web.Authorize<%= if not api do %>

  def new(conn, _) do
    render(conn, "new.html")
  end<% end %>

  def create(conn, %{"session" => params}) do
    case Phauxth.Login.verify(params) do
      {:ok, user} -><%= if api do %>
        token = Phoenix.Token.sign(<%= base %>.Web.Endpoint, "user auth", user.id)
        render(conn, <%= base %>.Web.SessionView, "info.json", %{info: token})
      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>
        put_session(conn, :user_id, user.id)
        |> success("You have been logged in", user_path(conn, :index))
      {:error, message} ->
        error(conn, message, session_path(conn, :new))<% end %>
    end
  end<%= if not api do %>

  def delete(conn, _) do
    configure_session(conn, drop: true)
    |> success("You have been logged out", page_path(conn, :index))
  end<% end %>
end
