defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticates the current user using sessions.

  You need to set a `user_context` module in the config and define a
  `get_by(%{"session_id" => session_id})` function (see the examples
  section below) in this module.

  See the documentation for Phauxth.Config for more information
  about the `user_context`.

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

  Add the following line to the pipeline you want to authenticate
  in the `web/router.ex` file:

      plug Phauxth.Authenticate

  Then, add the `user_context` module (the module you are using to handle
  user data) to the config:

      config :phauxth, user_context: MyApp.Accounts

  Finally, define a `get_by(%{"session_id" => session_id})` function
  in the `user_context` module (in this case, in MyApp.Accounts).

      def get_by(%{"session_id" => session_id}) do
        with %Session{user_id: user_id} <- Sessions.get_session(session_id),
        do: get_user(user_id)
      end

  This function should return a user struct or nil.
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
