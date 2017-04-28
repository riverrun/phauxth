defmodule <%= base %>.UserController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize
  alias <%= base %>.{Mailer, User}

  plug PhauxthConfirm when action in [:confirm]
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    {key, link} = PhauxthConfirm.gen_token_link(email)
    changeset = User.auth_changeset(%User{}, user_params, key)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        Mailer.ask_confirm(email, link)
        success conn, "User created successfully", user_path(conn, :index)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    render(conn, "show.html", user: user)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        success conn, "User updated successfully", user_path(conn, :show, user)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    Repo.delete!(user)
    configure_session(conn, drop: true)
    |> success("User deleted successfully", page_path(conn, :index))
  end

  def confirm(%Plug.Conn{private: %{phauxth_error: message}} = conn, _) do
    error conn, message, session_path(conn, :new)
  end
  def confirm(%Plug.Conn{private: %{phauxth_user: user}} = conn, _) do
    Mailer.receipt_confirm(user.email)
    success conn, message, session_path(conn, :new)
  end
end
