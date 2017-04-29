defmodule <%= base %>.Web.ConfirmController do
  use <%= base %>.Web, :controller

  import <%= base %>.Web.Authorize
  alias <%= base %>.Message

  plug PhauxthConfirm when action in [:confirm]

  def confirm_request(%Plug.Conn{private: %{phauxth_error: message}} = conn, _) do<%= if api do %>
    error(conn, :unauthorized, 401)<% else %>
    error(conn, message, session_path(conn, :new))<% end %>
  end
  def confirm_request(%Plug.Conn{private: %{phauxth_user: user}} = conn, _) do
    message = "Your account has been confirmed"
    Message.confirm_success(user.email)<%= if api do %>
    render(conn, <%= base %>.Web.ConfirmView, "info.json", %{info: message})<% else %>
    success(conn, message, session_path(conn, :new))<% end %>
  end
end
