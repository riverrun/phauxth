defmodule Phauxth.Remember.Utils do
  @moduledoc """
  Helper functions to be used with the Phauxth remember me functionality.
  """

  import Plug.Conn
  alias Phoenix.Token

  @doc """
  Add a Phoenix token as a remember me cookie.
  """
  def add_rem_cookie(conn, user_id, max_age \\ 604_800) do
    cookie = Token.sign(conn, "user auth", user_id)
    put_resp_cookie(conn, "remember_me", cookie, [http_only: true, max_age: max_age])
  end

  @doc """
  Delete the remember_me cookie.
  """
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end

end
