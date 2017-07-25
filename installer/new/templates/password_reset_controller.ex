defmodule <%= base %>Web.PasswordResetController do
  use <%= base %>Web, :controller<%= if api do %>

  alias <%= base %>.{Accounts, Accounts.User, Message}

  action_fallback <%= base %>Web.FallbackController<% else %>
  import <%= base %>Web.Authorize
  alias <%= base %>.{Accounts, Message}

  def new(conn, _params) do
    render(conn, "new.html")
  end<% end %>

  def create(conn, %{"password_reset" => %{"email" => email} = user_params}) do
    key = Phauxth.Confirm.gen_token()<%= if api do %>
    with {:ok, %User{}} <- Accounts.add_reset_token(user_params, key) do
      Message.reset_request(email, key)
      message = "Check your inbox for instructions on how to reset your password"
      conn
      |> put_status(:created)
      |> render(<%= base %>Web.PasswordResetView, "info.json", %{info: message})
    end
  end<% else %>
    case Accounts.add_reset_token(user_params, key) do
      {:ok, _user} ->
        Message.reset_request(email, key)
        message = "Check your inbox for instructions on how to reset your password"
        success(conn, message, user_path(conn, :index))
      {:error, _changeset} ->
        render(conn, "new.html")
    end
  end

  def edit(conn, %{"email" => email, "key" => key}) do
    render(conn, "edit.html", email: email, key: key)
  end<% end %>

  def update(conn, %{"password_reset" => params}) do
    case Phauxth.Confirm.PassReset.verify(params, Accounts) do
      {:ok, user} ->
        Accounts.update_user(user, params)
        Message.reset_success(user.email)
        message = "Your password has been reset"<%= if api do %>
        render(conn, <%= base %>Web.PasswordResetView, "info.json", %{info: message})<% else %>
        configure_session(conn, drop: true) |> success(message, session_path(conn, :new))<% end %>
      {:error, message} ->
        conn<%= if api do %>
        |> put_status(:unprocessable_entity)
        |> render(<%= base %>Web.PasswordResetView, "error.json", error: message)<% else %>
        |> put_flash(:error, message)
        |> render("edit.html", email: params["email"], key: params["key"])<% end %>
    end
  end
end
