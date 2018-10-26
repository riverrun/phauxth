defmodule Phauxth.CustomAuthenticate do
  use Phauxth.Authenticate.Base

  @impl true
  def get_user(conn, %{user_context: user_context}) do
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
  def call(conn, %{log_meta: log_meta} = opts) do
    meta = log_meta ++ [path: conn.request_path]
    super(conn, %{opts | log_meta: meta})
  end
end

defmodule Phauxth.AuthenticateTokenCookie do
  use Phauxth.Authenticate.Token

  @impl true
  def get_user(%Plug.Conn{req_cookies: %{"access_token" => token}}, opts) do
    token_mod = Config.token_module()
    verify_token(token, token_mod, opts)
  end
end
