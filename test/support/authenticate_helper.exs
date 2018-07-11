defmodule Phauxth.CustomAuthenticate do
  use Phauxth.Authenticate.Base

  @impl true
  def get_user(conn, user_context) do
    with id when not is_nil(id) <- get_session(conn, :user_id),
         do: user_context.get_by(%{"user_id" => id})
  end
end

defmodule Phauxth.AbsintheAuthenticate do
  use Phauxth.Authenticate.Token

  @impl true
  def set_user(user, conn) do
    conn
    |> put_private(:absinthe, %{context: %{current_user: user}})
    |> assign(:current_user, user)
  end
end

defmodule Phauxth.CustomCall do
  use Phauxth.Authenticate.Base

  @impl true
  def call(conn, {opts, log_meta}) do
    meta = log_meta ++ [path: conn.request_path]
    super(conn, {opts, meta})
  end
end
