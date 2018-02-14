defmodule Phauxth.TokenAuth do
  @moduledoc """
  Authenticates the user by verifying a Phauxth token.

  ## Token authentication

  This module looks for a token in the request headers. It then uses
  Phauxth.Token to check that it is valid. If it is valid, user information
  is retrieved from the database.

  This process can be customized by overriding the `get_user` function
  in Phauxth.Authenticate.Base.

  ## Options

  There are also options for signing / verifying the token.
  See the documentation for the Phauxth.Token module for details.

  ## Examples

  """

  use Phauxth.Authenticate.Token
end
