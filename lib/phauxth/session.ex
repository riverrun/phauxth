defmodule Phauxth.Session do
  @moduledoc """
  Session-related functions.
  """

  import Plug.Conn

  @doc """
  Get the session id and user id for the current user.
  """
  def get_session_data(conn) do
    with <<session_id::binary-size(17), user_id::binary>> <-
           get_session(conn, :phauxth_session_id),
         do: {session_id, user_id}
  end

  @doc """
  Add the phauxth_session_id to the conn.
  """
  def add_session(conn, session_id, user_id) do
    put_session(conn, :phauxth_session_id, session_id <> to_string(user_id))
    |> configure_session(renew: true)
  end

  @doc """
  Generate a session id.

  The session id is a 17-character long string. The first character
  indicates if the session is fresh - if the user is newly logged in.
  The other 16 characters are randomly generated.
  """
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
  def fresh_session?(conn) do
    get_session(conn, :phauxth_session_id) |> check_session_id
  end

  defp check_session_id("F" <> _), do: true
  defp check_session_id(_), do: false
end
