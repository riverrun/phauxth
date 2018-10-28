defmodule Phauxth.Remember do
  @moduledoc """
  Remember me module.

  Checks for a `remember_me` cookie, which contains a token. The token is
  then checked, and if it is valid, the user is added to the session.

  You must define a `create_session` function in the `user_context`
  module if you are using this Plug. The `create_session` function
  should return `{:ok, session}` or `{:error, message}`.

  This module also contains functions to add / delete the `remember_me`
  cookie.

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for signing / verifying the token.
  See the documentation for the Phauxth.Token module for details.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate
      plug Phauxth.Remember

  Make sure you add the Phauxth.Remember Plug after Phauxth.Authenticate.
  """

  use Phauxth.Authenticate.Base
  alias Phauxth.{Authenticate, Config}

  @max_age 7 * 24 * 60 * 60

  @impl Plug
  def call(%Plug.Conn{assigns: %{current_user: %{}}} = conn, _), do: conn

  def call(%Plug.Conn{req_cookies: %{"remember_me" => _token}} = conn, opts) do
    super(conn, opts)
  end

  def call(conn, _), do: conn

  @impl Phauxth.Authenticate.Base
  def authenticate(%Plug.Conn{req_cookies: %{"remember_me" => token}}, opts) do
    with {:ok, user_id} <- Config.token_module().verify(token, opts),
         do: get_user({:ok, %{"user_id" => user_id}})
  end

  @impl Phauxth.Authenticate.Base
  def set_user(nil, conn), do: super(nil, conn)

  def set_user(user, conn) do
    {:ok, %{id: session_id}} = Config.user_context().create_session(user)
    conn = Authenticate.add_session(conn, session_id)
    super(user, conn)
  end

  @doc """
  Adds a remember me cookie to the conn.
  """
  @spec add_rem_cookie(Plug.Conn.t(), integer, integer) :: Plug.Conn.t()
  def add_rem_cookie(conn, user_id, max_age \\ @max_age) do
    token_mod = Config.token_module()
    cookie = token_mod.sign(user_id, max_age: max_age)
    put_resp_cookie(conn, "remember_me", cookie, http_only: true, max_age: max_age)
  end

  @doc """
  Deletes the remember_me cookie from the conn.
  """
  @spec delete_rem_cookie(Plug.Conn.t()) :: Plug.Conn.t()
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end
end
