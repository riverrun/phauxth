defmodule Phauxth.CustomAuthenticate do
  use Phauxth.Authenticate.Base

  @impl true
  def get_user(conn, session_module) do
    with id when not is_nil(id) <- get_session(conn, :user_id),
         do: session_module.get_by(%{"user_id" => id})
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

defmodule Phauxth.AuthenticateTokenCookie do
  use Phauxth.Authenticate.Token

  @impl true
  def get_user(%Plug.Conn{req_cookies: %{"access_token" => token}}, opts) do
    token_mod = Config.token_module()
    verify_token(token, token_mod, opts)
  end
end
