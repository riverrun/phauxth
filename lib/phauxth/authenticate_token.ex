defmodule Phauxth.AuthenticateToken do
  @moduledoc """
  Authenticates the user by verifying a Phauxth token.

  This module looks for a token in the request headers,
  checks to see if the token is valid and then sets the `current_user`
  value accordingly.

  If you want to store the token in a cookie, or customize this Plug
  in any other way, see the documentation for Phauxth.Authenticate.Token.

  ## Configuration / setup

  Add the `user_context` module (the module you are using to handle
  user data) to the config:

      config :phauxth, user_context: MyApp.Accounts

  The user_context module (in this case, MyApp.Accounts) needs to have a
  `get_by(attrs)` function, which returns either a user struct or nil.

  You also need to define a token module that implements the Phauxth.Token
  behaviour. See the documentation for the Phauxth.Token module for details.

  ## Options

  There are three main options:

    * `:user_context` - the user_context module
      * this can also be set in the config
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list
    * `:max_age` - the maximum age for the token
      * the default is 14400 seconds - 4 hours

  The options keyword list is also passed to the token verify function.
  See the documentation for Phauxth.Token for information about defining
  and setting the token module.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.AuthenticateToken

  To set the max_age to two hours:

      plug Phauxth.AuthenticateToken, max_age: 7200

  """

  use Phauxth.Authenticate.Token
end
