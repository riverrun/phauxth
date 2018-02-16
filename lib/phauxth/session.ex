defmodule Phauxth.Session do
  @moduledoc """
  Session-related functions.
  """

  import Plug.Conn

  @doc """
  Add the session_id to the conn.
  """
  @spec add_session(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def add_session(conn, session_id) do
    put_session(conn, :session_id, session_id)
    |> configure_session(renew: true)
  end

  def check_expiry(%{expires_at: expires_at} = session) do
    expires_at > System.system_time(:second) and session || nil
  end

  @doc """
  Generate a session id.

  The session id is a 17-character long string. The first character
  indicates if the session is fresh - if the user is newly logged in.
  The other 16 characters are randomly generated.
  """
  @spec gen_session_id(map, binary) :: binary
  def gen_session_id(sessions, fresh) do
    id = gen_id(fresh)
    (Map.has_key?(sessions, id) and gen_session_id(sessions, fresh)) || id
  end

  defp gen_id(fresh) do
    "#{fresh}#{:crypto.strong_rand_bytes(12) |> Base.encode64()}"
  end

  @doc """
  Check if the user session is fresh - newly logged in.
  """
  @spec fresh_session?(Plug.Conn.t()) :: boolean
  def fresh_session?(conn) do
    get_session(conn, :session_id) |> check_session_id
  end

  defp check_session_id("F" <> _), do: true
  defp check_session_id(_), do: false
end
