defmodule Phauxth.Login do
  @moduledoc """
  Module to handle login.

  See the documentation for the `verify` function for details.
  """

  use Phauxth.Login.Base

  import Plug.Conn

  @doc """
  Add the phauxth_session_id to the conn.
  """
  def add_session(conn, session_id, user_id) do
    put_session(conn, :phauxth_session_id, session_id <> to_string(user_id))
    |> configure_session(renew: true)
  end

  @doc """
  Generate a session id.
  """
  def gen_session_id(fresh) do
    "#{fresh}#{:crypto.strong_rand_bytes(12) |> Base.encode64()}"
  end
end
