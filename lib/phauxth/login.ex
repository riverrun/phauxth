defmodule Phauxth.Login do
  @moduledoc """
  Module to handle login.

  See the documentation for the `verify` function for details.
  """

  use Phauxth.Login.Base
  import Plug.Conn

  def add_session(conn, session_id, user_id) do
    put_session(conn, :phauxth_session_id, session_id <> to_string(user_id))
    |> configure_session(renew: true)
  end

  # the phauxth_session_id is the concatenation of:
  # * fresh - is the login fresh or stale? F=fresh, S=stale
  # * random 16-byte string
  # * the user_id (only in the cookie)
  def gen_session_id(fresh) do
    "#{fresh}#{:crypto.strong_rand_bytes(12) |> Base.encode64}"
  end
end
