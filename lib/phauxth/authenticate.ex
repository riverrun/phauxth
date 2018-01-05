defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using sessions or api tokens.

  For information about customizing this Plug, see the documentation
  for Phauxth.Authenticate.Base.

  ## Session authentication

  This module checks the current Plug session for a `phauxth_session_id`,
  which contains a session id and user id. It then checks the user
  schema to see if the session id is valid. The sessions should be stored
  in a map with session ids as keys and timestamps as values.

  This process can be customized by overriding the `get_user` function
  in Phauxth.Authenticate.Base.

  ## Token authentication

  This module looks for a token in the request headers. It then uses
  Phauxth.Token to check that it is valid. If it is valid, user information
  is retrieved from the database.

  This process can be customized by overriding the `get_user` function
  in Phauxth.Authenticate.Base.

  ## Options

  There are four options:

    * `:method` - the method used to authenticate the user
      * this is either `:session` (using sessions) or `:token` (using api tokens)
      * the default is `:session`
    * `:max_age` - the length of the validity of the session / token
      * the default is four hours
    * `:user_context` - the user context module to be used
      * the default is MyApp.Accounts
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for signing / verifying the token.
  See the documentation for the Phauxth.Token module for details.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add the token method option:

      plug Phauxth.Authenticate, method: :token

  """

  use Phauxth.Authenticate.Base

  @doc """
  Check if the user session is fresh - newly logged in.
  """
  def fresh_session?(conn) do
    get_session(conn, :phauxth_session_id) |> check_session_id
  end

  defp check_session_id("F" <> _), do: true
  defp check_session_id(_), do: false
end
