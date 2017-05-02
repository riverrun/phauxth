defmodule <%= base %>.Web.ConfirmController do
  use <%= base %>.Web, :controller

  import <%= base %>.Web.Authorize
  alias <%= base %>.{Accounts, Message}

  plug Phauxth.Confirm

  def new(%Plug.Conn{private: %{phauxth_error: message}} = conn, _) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error(conn, message, session_path(conn, :new))<% end %>
  end
  def new(%Plug.Conn{private: %{phauxth_user: user}} = conn, _) do
    Accounts.confirm_user(user)
    message = "Your account has been confirmed"
    Message.confirm_success(user.email)<%= if api do %>
    render(conn, <%= base %>.Web.ConfirmView, "info.json", %{info: message})<% else %>
    success(conn, message, session_path(conn, :new))<% end %>
  end
end
