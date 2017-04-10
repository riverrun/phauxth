defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions or Phoenix token.

  ## Example using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add a context:

      plug Phauxth.Authenticate, context: MyApp.Web.Endpoint

  """

  use Phauxth.Authenticate.Base

end
