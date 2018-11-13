defmodule Phauxth.Login do
  @moduledoc """
  Module to login users.

  Before using this module, you will need to add the `crypto_module` value
  to the config. The recommended module is Comeonin.Argon2 - other valid
  values are Comeonin.Bcrypt and Comeonin.Pkdf2.

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

  import Plug.Conn

  @doc """
  Adds the session_id to the conn.
  """
  @spec add_session(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def add_session(conn, session_id) do
    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end
end
