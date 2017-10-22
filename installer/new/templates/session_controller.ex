defmodule <%= base %>Web.SessionController do
  use <%= base %>Web, :controller

  import <%= base %>Web.Authorize
  alias <%= base %>.Accounts<%= if confirm do %>
  alias Phauxth.Confirm.Login<% else %>
  alias Phauxth.Login<% end %><%= if api do %>

  plug :guest_check when action in [:create]<% else %>

  plug :guest_check when action in [:new, :create]
  plug :id_check when action in [:delete]

  def new(conn, _) do
    render(conn, "new.html")
  end<% end %>

  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"session" => params}) do
    case Login.verify(params, Accounts) do
      {:ok, user} -><%= if api do %>
        token = Phauxth.Token.sign(conn, user.id)
        render(conn, <%= base %>Web.SessionView, "info.json", %{info: token})
      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>
        session_id = Login.gen_session_id("F")
        Accounts.add_session(user, session_id, System.system_time(:second))
        Login.add_session(conn, session_id, user.id)<%= if remember do %>
        |> add_remember_me(user.id, params)<% end %>
        |> success("You have been logged in", user_path(conn, :index))
      {:error, message} ->
        error(conn, message, session_path(conn, :new))<% end %>
    end
  end<%= if not api do %>

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    <<session_id::binary-size(17), _::binary>> = get_session(conn, :phauxth_session_id)
    Accounts.delete_session(user, session_id)
    delete_session(conn, :phauxth_session_id)<%= if remember do %>
    |> Phauxth.Remember.delete_rem_cookie<% end %>
    |> success("You have been logged out", page_path(conn, :index))
  end<%= if remember do %>

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Phauxth.Remember.add_rem_cookie(conn, user_id)
  end
  defp add_remember_me(conn, _, _), do: conn<% end %><% end %>
end
