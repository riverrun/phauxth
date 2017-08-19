defmodule <%= base %>Web.UserController do
  use <%= base %>Web, :controller

  import <%= base %>Web.Authorize
  alias Phauxth.Log
  alias <%= base %>.{Accounts, Accounts.User<%= if confirm do %>, Message<% end %>}<%= if api do %>

  action_fallback <%= base %>Web.FallbackController<% end %>

  plug :user_check when action in [:index, :show]<%= if api do %>
  plug :id_check when action in [:update, :delete]<% else %>
  plug :id_check when action in [:edit, :update, :delete]<% end %>

  def index(conn, _) do
    users = Accounts.list_users()<%= if api do %>
    render(conn, "index.json", users: users)<% else %>
    render(conn, "index.html", users: users)<% end %>
  end<%= if not api do %>

  def new(conn, _) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end<% end %><%= if confirm do %>

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    key = Phauxth.Token.sign(conn, %{"email" => email})<% else %>
  def create(conn, %{"user" => user_params}) do<% end %>
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      Log.info(%Log{user: user.id, message: "user created"})<%= if confirm do %>
      Message.confirm_request(email, key)<% end %><%= if api do %>
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)<% else %>
      success(conn, "User created successfully", session_path(conn, :new))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)<% end %>
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = id == to_string(user.id) and user || Accounts.get(id)<%= if api do %>
    render(conn, "show.json", user: user)<% else %>
    render(conn, "show.html", user: user)<% end %>
  end<%= if not api do %>

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end<% end %>

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do<%= if api do %>
      render(conn, "show.json", user: user)<% else %>
      success(conn, "User updated successfully", user_path(conn, :show, user))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)<% end %>
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    with {:ok, %User{}} <- Accounts.delete_user(user) do<%= if api do %>
      send_resp(conn, :no_content, "")<% else %>
      configure_session(conn, drop: true)
      |> success("User deleted successfully", session_path(conn, :new))<% end %>
    end
  end
end
