defmodule Phauxth.AuthenticateToken do
  @moduledoc """
  Authenticates the user by verifying a Phauxth token.

  You need to define a `get_by(attrs)` function in the `user_context`
  module you are using - see the documentation for Phauxth.Config
  for more information about the `user_context`.

  ## Token authentication

  This module looks for a token in the request headers. It then uses the
  `token_module` (which you need to set in the config) to check if
  it is valid. If it is valid, the `get_by` function in the `user_context`
  module is called, to get user information from the database.

  If you want to store the token in a cookie, see the documentation for
  Phauxth.Authenticate.Token, which has an example of how you can create
  a custom module to verify tokens stored in cookies.

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for verifying the token. See the documentation
  for the Phauxth.Token module for details.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.AuthenticateToken

  Then, add the `user_context` module (the module you are using to handle
  user data) to the config:

      config :phauxth, user_context: MyApp.Accounts

  Finally, define a `get_by(attrs)` function in the `user_context`
  module (in this case, in MyApp.Accounts). This function should
  return a user struct or nil, and the `attrs` should be the data
  which was used to sign the token.
  """

  use Phauxth.Authenticate.Token
end
