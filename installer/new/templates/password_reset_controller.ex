defmodule <%= base %>.Web.PasswordResetController do
  use <%= base %>.Web, :controller<%= if not api do %>
  import <%= base %>.Web.Authorize<% end %>
  alias <%= base %>.{Accounts, Accounts.User, Message}<%= if api do %>

  action_fallback <%= base %>.Web.FallbackController<% end %>

  plug Phauxth.Confirm.PassReset when action in [:update]<%= if not api do %>

  def new(conn, _params) do
    render conn, "new.html"
  end<% end %>

  def create(conn, %{"password_reset" => %{"email" => email} = user_params}) do
    {key, link} = Phauxth.Confirm.gen_token_link(email)<%= if api do %>
    with {:ok, %User{}} <- Accounts.add_reset_token(user_params, key) do
      Message.reset_request(email, link)
      message = "Check your inbox for instructions on how to reset your password"
      conn
      |> put_status(:created)
      |> render(<%= base %>.Web.PasswordResetView, "info.json", %{info: message})<% else %>
    case Accounts.add_reset_token(user_params, key) do
      {:ok, _user} ->
        Message.reset_request(email, link)
        message = "Check your inbox for instructions on how to reset your password"
        success conn, message, user_path(conn, :index)
      {:error, _changeset} ->
        render conn, "new.html"<% end %>
    end
  end<%= if api do %>

  def update(%Plug.Conn{private: %{phauxth_error: message}} = conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(<%= base %>.Web.PasswordResetView, "error.json", error: message)
  end
  def update(%Plug.Conn{private: %{phauxth_user: user}} = conn, params) do
    Accounts.update_user(user, params)
    Message.reset_success(user.email)
    message = "Your password has been reset"
    render(conn, <%= base %>.Web.PasswordResetView, "info.json", %{info: message})
  end<% else %>

  def edit(conn, %{"email" => email, "key" => key}) do
    render conn, "edit.html", email: email, key: key
  end

  def update(%Plug.Conn{private: %{phauxth_error: message}} = conn,
   %{"password_reset" => %{"email" => email, "key" => key}}) do
    conn
    |> put_flash(:error, message)
    |> render("edit.html", email: email, key: key)
  end
  def update(%Plug.Conn{private: %{phauxth_user: user}} = conn, params) do
    Accounts.update_user(user, params)
    Message.reset_success(user.email)
    message = "Your password has been reset"
    configure_session(conn, drop: true) |> success(message, session_path(conn, :new))
  end<% end %>
end
