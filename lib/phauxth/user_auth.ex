defmodule Phauxth.UserAuth do
  @moduledoc """
  Authenticates the current user, using Plug sessions and the user id.
  """

  use Phauxth.Authenticate.Base
end
