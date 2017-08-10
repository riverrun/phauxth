defmodule <%= base %>Web.PasswordResetController do
  use <%= base %>Web, :controller<%= if api do %>

  alias <%= base %>.{Accounts, Accounts.User, Message}

  action_fallback <%= base %>Web.FallbackController<% else %>
  import <%= base %>Web.Authorize
  alias <%= base %>.{Accounts, Accounts.User, Message}

  def new(conn, _params) do
    render(conn, "new.html")
  end<% end %>

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    with %User{} = user <- Accounts.get_by(%{"email" => email}) do
      key = Phauxth.Token.sign(conn, %{"email" => email})
      Accounts.add_reset(user)
      Message.reset_request(email, key)
      message = "Check your inbox for instructions on how to reset your password"<%= if api do %>
      conn
      |> put_status(:created)
      |> render(<%= base %>Web.PasswordResetView, "info.json", %{info: message})
    end
  end<% else %>
      success(conn, message, user_path(conn, :index))
    else
      nil -> render(conn, "new.html")
    end
  end

  def edit(conn, %{"key" => key}) do
    render(conn, "edit.html", key: key)
  end<% end %>

  def update(conn, %{"password_reset" => params}) do
    case Phauxth.Confirm.PassReset.verify(params, Accounts, {conn, 1200}) do
      {:ok, user} ->
        Accounts.update_password(user, params)
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
