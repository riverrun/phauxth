defmodule Phauxth.Login do
  @moduledoc """
  Module to login users.

  Before using this module, you will need to add the `crypto_module` value
  to the config. The `crypto_module` must implement the Comeonin behaviour.

  ## Options

  There are two options:

    * `:user_context` - the user_context module
      * this can also be set in the config
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for verifying the password. See the documentation
  for the `crypto_module`'s `check_pass` function for details.
  """

  use Phauxth.Login.Base
end
