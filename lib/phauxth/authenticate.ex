defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions or api tokens.

  ## Options

  There are four options:

    * method - the method used to authenticate the user
      * this is either `:session` (using sessions) or `:token` (using api tokens)
      * the default is `:session`
    * max_age - the length of the validity of the token
      * the default is four hours
    * user_context - the user context module to be used
      * the default is MyApp.Accounts
    * log_meta - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  In addition, there are also options for generating the token.
  See the documentation for the Phauxth.Token module for details.

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add the token method option:

      plug Phauxth.Authenticate, method: :token

  """

  use Phauxth.Authenticate.Base

end
