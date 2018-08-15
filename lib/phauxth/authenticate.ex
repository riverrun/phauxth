defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticates the current user, using Phauxth sessions and a session
  id.

  You need to define a `get_by(%{"session_id" => session_id})` function
  in the user_context / session_context module you are using (which is MyApp.Accounts by
  default).

  For information about customizing this Plug, see the documentation
  for Phauxth.Authenticate.Base.

  ## Phauxth session authentication

  This module checks the current Plug session for a `session_id`. It then
  checks to see if the session id is valid.

  This process can be customized by overriding the `get_user` function
  in Phauxth.Authenticate.Base.

  ## Options

  There are two options:

    * `:user_context` - the user context module to be used
      * the default is MyApp.Accounts
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate

  And if you are using a different user context module:

      plug Phauxth.Authenticate, user_context: MyApp.Sessions

  In the example above, you need to have the `get_by/1` function
  defined in MyApp.Sessions.
  """

  use Phauxth.Authenticate.Base

  import Plug.Conn

  @doc """
  Adds the session_id to the conn.
  """
  @spec add_session(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def add_session(conn, session_id) do
    put_session(conn, :session_id, session_id)
    |> configure_session(renew: true)
  end
end
