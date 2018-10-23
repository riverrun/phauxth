defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticates the current user, using Phauxth sessions and a session
  id.

  You need to define a `get_by(%{"session_id" => session_id})` function
  in the `user_context` module you are using - see the documentation
  for Phauxth.Config for more information about the `user_context`.

  For information about customizing this Plug, see the documentation
  for Phauxth.Authenticate.Base.

  ## Phauxth session authentication

  This module checks the current Plug session for a `session_id`. It then
  checks to see if the session id is valid.

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate

  And if you are using a different users module:

      plug Phauxth.Authenticate, user_context: MyApp.Users

  In the example above, you need to have the `get_by/1` function
  defined in MyApp.Users.
  """

  use Phauxth.Authenticate.Base

  import Plug.Conn

  @doc """
  Adds the session_id to the conn.
  """
  @spec add_session(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def add_session(conn, session_id) do
    conn
    |> put_session(:session_id, session_id)
    |> configure_session(renew: true)
  end
end
