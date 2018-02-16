defmodule Phauxth.SessionAuth do
  @moduledoc """
  Authenticates the current user, using Phauxth sessions and a session
  id.

  For information about customizing this Plug, see the documentation
  for Phauxth.Authenticate.Base and Phauxth.Authenticate.Session.

  ## Phauxth session authentication

  This module checks the current Plug session for a `phauxth_session_id`,
  which contains a session id and user id. It then checks the user
  schema to see if the session id is valid. The sessions should be stored
  in a map with session ids as keys and timestamps as values.

  This process can be customized by overriding the `get_user` function
  in Phauxth.Authenticate.Base.

  ## Options

  There are three options:

    * `:max_age` - the length of the validity of the session / token
      * the default is four hours
    * `:user_context` - the user context module to be used
      * the default is MyApp.Accounts
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.SessionAuth

  """

  use Phauxth.Authenticate.Session
end
