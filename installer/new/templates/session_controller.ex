defmodule <%= base %>Web.SessionController do
  use <%= base %>Web, :controller

  import <%= base %>Web.Authorize<%= if confirm do %>
  alias Phauxth.Confirm.Login<% else %>
  alias Phauxth.Login<% end %><%= if not api do %>

  def new(conn, _) do
    render(conn, "new.html")
  end<% end %>

  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"session" => params}) do
    case Login.verify(params, <%= base %>.Accounts) do
      {:ok, user} -><%= if api do %>
        token = Phauxth.Token.sign(conn, user.id)
        render(conn, <%= base %>Web.SessionView, "info.json", %{info: token})
      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>
        put_session(conn, :user_id, user.id)
        |> configure_session(renew: true)
        |> success("You have been logged in", user_path(conn, :index))
      {:error, message} ->
        error(conn, message, session_path(conn, :new))<% end %>
    end
  end<%= if not api do %>

  def delete(conn, _) do
    delete_session(conn, :user_id)
    |> success("You have been logged out", page_path(conn, :index))
  end<% end %>
end
