defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions or Phoenix tokens.

  ## Options

  There are three options:

    * token - the token key source to use when using Phoenix token
      * the default is nil, meaning the user will be authenticated using sessions
      * in most cases, this will be the name of the endpoint you are using
        * can also be `Plug.Conn`, `Phoenix.Socket` or a string representing the secret key base
      * see the documentation for Phoenix.Token for more information
    * max_age - the length of the validity of the token
      * the default is one week
    * user_context - the user context module to be used
      * the default is MyApp.Accounts

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add the token key source:

      plug Phauxth.Authenticate, token: MyApp.Web.Endpoint

  """

  use Phauxth.Authenticate.Base

end
