defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions or Phoenix tokens.

  ## Options

  There are two options:

    * context - the context to use when using Phoenix token
      * in most cases, this will be the name of the endpoint you are using
      * see the documentation for Phoenix.Token for more information
    * max_age - the length of the validity of the token
      * the default is one week

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add a context:

      plug Phauxth.Authenticate, context: MyApp.Web.Endpoint

  """

  use Phauxth.Authenticate.Base

end
