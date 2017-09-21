defmodule <%= base %>Web.ConfirmController do
  use <%= base %>Web, :controller

  import <%= base %>Web.Authorize
  alias <%= base %>.Accounts

  def index(conn, params) do
    case Phauxth.Confirm.verify(params, Accounts) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        message = "Your account has been confirmed"
        Accounts.Message.confirm_success(user.email)<%= if api do %>
        render(conn, <%= base %>Web.ConfirmView, "info.json", %{info: message})
      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>
        success(conn, message, session_path(conn, :new))
      {:error, message} ->
        error(conn, message, session_path(conn, :new))<% end %>
    end
  end
end
