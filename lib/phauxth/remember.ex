defmodule Phauxth.Remember do
  @moduledoc """
  Remember me module.

  Checks for a `remember_me` cookie, which contains a token. The token is
  then checked, and if it is valid, the user is added to the session.

  This module also contains functions to add / delete the `remember_me`
  cookie.

  ## Options

  There are three options:

    * `:session_module` - the sessions module to be used
      * the default is Phauxth.Config.session_module()
    * `:session_id_func` - the function used to set the session id
      * the default is `&Phauxth.Utils.uuid4/0`
    * `:max_age` - the length of the validity of the cookie / token
      * the default is one week
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  In addition, there are also options for generating the token.

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

  @impl true
  def init(opts) do
    {
      {
        Keyword.get(opts, :max_age, @max_age),
        Keyword.get(opts, :session_module, Config.session_module()),
        opts
      },
      Keyword.get(opts, :session_id_func, &Phauxth.Utils.uuid4/0),
      Keyword.get(opts, :log_meta, [])
    }
  end

  @impl true
  def call(%Plug.Conn{assigns: %{current_user: %{}}} = conn, _), do: conn

  def call(
        %Plug.Conn{req_cookies: %{"remember_me" => token}} = conn,
        {opts, session_id_func, log_meta}
      ) do
    Config.token_module()
    |> get_user_data(token, opts)
    |> report(log_meta)
    |> set_user(conn)
    |> Authenticate.add_session(session_id_func.())
  end

  def call(conn, _), do: conn

  @doc """
  Gets the user data from the token.
  """
  @spec get_user_data(Plug.Conn.t(), String.t(), tuple) :: map | nil
  def get_user_data(token_mod, token, {_, session_module, opts}) do
    with {:ok, user_id} <- token_mod.verify(token, opts),
         do: session_module.get_by(%{"user_id" => user_id})
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
