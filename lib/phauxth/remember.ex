defmodule Phauxth.Remember do
  @moduledoc """
  Remember me module.

  Checks for a `remember_me` cookie, which contains a token. The token is
  then checked, and if it is valid, the user is added to the session.

  This module also contains functions to add / delete the `remember_me`
  cookie.

  If you want to customize this Plug in any way, see the documentation for
  Phauxth.Authenticate.Remember.

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

  use Phauxth.Authenticate.Remember

  @doc """
  Adds a remember me cookie to the conn.
  """
  # In v3.0, move all cookie options to a keyword list.
  @spec add_rem_cookie(Plug.Conn.t(), integer | binary, integer) :: Plug.Conn.t()
  def add_rem_cookie(
        conn,
        user_id,
        max_age \\ @max_age,
        extra \\ "",
        token_module \\ nil,
        domain \\ nil
      ) do
    token_module = token_module || Config.token_module()
    cookie = token_module.sign(user_id, max_age: max_age)

    if domain do
      put_resp_cookie(conn, "remember_me", cookie,
        http_only: true,
        max_age: max_age,
        extra: extra,
        domain: domain
      )
    else
      put_resp_cookie(conn, "remember_me", cookie, http_only: true, max_age: max_age, extra: extra)
    end
  end

  @doc """
  Deletes the remember_me cookie from the conn.
  """
  @spec delete_rem_cookie(Plug.Conn.t()) :: Plug.Conn.t()
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end
end
