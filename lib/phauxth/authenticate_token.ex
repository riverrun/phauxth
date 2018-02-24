defmodule Phauxth.AuthenticateToken do
  @moduledoc """
  Authenticates the user by verifying a Phauxth token.

  You need to define a `get_by(attrs)` function in the user_context
  module you are using (which is MyApp.Accounts by default).

  ## Token authentication

  This module looks for a token in the request headers. It then uses
  Phauxth.Token to check that it is valid. If it is valid, user information
  is retrieved from the database.

  ## Options

  There are three options:

    * `:max_age` - the length the token is valid for
      * the default is 4 hours
    * `:user_context` - the user context module to be used
      * the default is MyApp.Accounts
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for signing / verifying the token.
  See the documentation for the Phauxth.Token module for details.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.AuthenticateToken

  And if you are using a different user context module:

      plug Phauxth.AuthenticateToken, user_context: MyApp.Sessions

  In the example above, you need to have the `get_by/1` function
  defined in MyApp.Sessions.
  """

  use Phauxth.Authenticate.Token
end
