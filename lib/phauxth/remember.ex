defmodule Phauxth.Remember do
  @moduledoc """
  Remember me module.

  Checks for a `remember_me` cookie, which contains a token. The token is
  then checked, and if it is valid, the user is added to the session.

  This module also contains functions to add / delete the `remember_me`
  cookie.

  ## Configuration / setup

  Add the `user_context` module (the module you are using to handle
  user data) to the config:

      config :phauxth, user_context: MyApp.Accounts

  The user_context module (in this case, MyApp.Accounts) needs to have a
  `get_by(attrs)` function, which returns either a user struct or nil,
  and a `create_session(user)` function, which returns `{:ok, session}` or
  `{:error, message}`.

  You also need to define a token module that implements the Phauxth.Token
  behaviour. See the documentation for the Phauxth.Token module for details.

  ## Options

  There are four main options:

    * `:user_context` - the user_context module
      * this can also be set in the config
    * `:token_module` - the token module
      * this can also be set in the config
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list
    * `:max_age` - the maximum age for the token
      * the default is 604_800 seconds -  1 week

  The options keyword list is also passed to the token verify function.
  See the documentation for Phauxth.Token for information about defining
  and setting the token module.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate
      plug Phauxth.Remember

  Make sure you add the Phauxth.Remember Plug after Phauxth.Authenticate.
  """

  use Phauxth.Authenticate.Base

  alias Phauxth.Config

  @max_age 7 * 24 * 60 * 60

  @impl Plug
  def init(opts) do
    create_session_func =
      opts[:create_session_func] ||
        raise """
        Phauxth.Remember - you need to set a `create_session_func` in the opts
        """

    unless is_function(create_session_func, 1) do
      raise """
      Phauxth.Remember - the `create_session_func` should be a function
      that takes one argument
      """
    end

    opts =
      opts
      |> Keyword.put_new(:max_age, 14_400)
      |> Keyword.put_new(:token_module, Config.token_module())
      |> super()

    {create_session_func, opts}
  end

  @impl Plug
  def call(%Plug.Conn{assigns: %{current_user: %{}}} = conn, _), do: conn

  def call(%Plug.Conn{req_cookies: %{"remember_me" => _}} = conn, {create_session_func, opts}) do
    conn |> super(opts) |> add_session(create_session_func)
  end

  def call(conn, _), do: conn

  @impl Phauxth.Authenticate.Base
  def authenticate(%Plug.Conn{req_cookies: %{"remember_me" => token}}, user_context, opts) do
    token_module = opts[:token_module]

    with {:ok, user_id} <- token_module.verify(token, opts),
         do: get_user({:ok, %{"user_id" => user_id}}, user_context)
  end

  @impl Phauxth.Authenticate.Base
  def set_user(nil, conn), do: super(nil, delete_rem_cookie(conn))
  def set_user(user, conn), do: super(user, conn)

  defp add_session(%Plug.Conn{assigns: %{current_user: %{}}} = conn, create_session_func) do
    {:ok, %{id: session_id}} = create_session_func.(conn)

    conn
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end

  defp add_session(conn, _), do: conn

  @doc """
  Adds a remember me cookie to the conn.
  """
  @spec add_rem_cookie(Plug.Conn.t(), integer, integer) :: Plug.Conn.t()
  def add_rem_cookie(conn, user_id, max_age \\ @max_age, extra \\ "", token_module \\ nil) do
    token_module = token_module || Config.token_module()
    cookie = token_module.sign(user_id, max_age: max_age)
    put_resp_cookie(conn, "remember_me", cookie, http_only: true, max_age: max_age, extra: extra)
  end

  @doc """
  Deletes the remember_me cookie from the conn.
  """
  @spec delete_rem_cookie(Plug.Conn.t()) :: Plug.Conn.t()
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end
end
