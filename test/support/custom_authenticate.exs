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
  def authenticate(%Plug.Conn{req_cookies: %{"access_token" => token}}, opts) do
    verify_token(token, opts)
  end
end
