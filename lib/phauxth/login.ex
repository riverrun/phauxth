defmodule Phauxth.Login do
  @moduledoc """
  Module to login users.

  Before using this module, you will need to add the `crypto_module` value
  to the config. The recommended module is Comeonin.Argon2 - other valid
  values are Comeonin.Bcrypt and Comeonin.Pkdf2.

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for verifying the password. See the documentation
  for the `crypto_module`'s `check_pass` function for details.
  """

  use Phauxth.Login.Base
end
