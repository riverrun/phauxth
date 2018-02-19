defmodule Phauxth.TokenAuth do
  @moduledoc """
  Authenticates the user by verifying a Phauxth token.

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

      plug Phauxth.TokenAuth

  """

  use Phauxth.Authenticate.Token
end
