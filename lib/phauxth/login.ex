defmodule Phauxth.Login do
  @moduledoc """
  Module to login users.

  ## Options

  There is one option:

    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list
  """

  use Phauxth.Login.Base
end
