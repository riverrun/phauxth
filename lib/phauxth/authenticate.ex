defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticates the current user using sessions.

  This module checks the current Plug session for a `phauxth_session_id`,
  checks to see if the session id is valid and then sets the `current_user`
  value accordingly.

  For information about customizing this Plug, see the documentation
  for Phauxth.Authenticate.Base.

  ## Configuration / setup

  Add the `user_context` module (the module you are using to handle
  user data) to the config:

      config :phauxth, user_context: MyApp.Accounts

  The user_context module (in this case, MyApp.Accounts) needs to have a
  `get_by(%{"session_id" => session_id})` function, which returns either
  a user struct or nil.

  In the example below, the Sessions.get_session/1 function retrieves the
  data and checks if the session is still valid (has not expired, etc.).

      def get_by(%{"session_id" => session_id}) do
        with %Session{user_id: user_id} <- Sessions.get_session(session_id),
        do: get_user(user_id)
      end

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  ## Examples

  Add the following line to the pipeline you want to authenticate
  in the `web/router.ex` file:

      plug Phauxth.Authenticate

  """

  use Phauxth.Authenticate.Base
end
