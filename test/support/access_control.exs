defmodule Phauxth.AccessControl do

  import Plug.Conn

  def authorize_role(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
    full_check(conn, Keyword.get(opts, :roles, []), current_user)
  end

  def authorize_id(%Plug.Conn{params: %{"id" => id},
    assigns: %{current_user: current_user}} = conn, _opts) do
    id_check(conn, id, current_user)
  end

  defp full_check(conn, _, nil), do: nouser_error(conn)
  defp full_check(conn, roles, %{role: role}) do
    if role in roles, do: conn, else: nopermit_error(conn, role)
  end

  defp id_check(conn, _id, nil), do: nouser_error(conn)
  defp id_check(conn, id, current_user) do
    if id == to_string(current_user.id) do
      conn
    else
      nopermit_error(conn, current_user.role)
    end
  end

  defp nouser_error(%Plug.Conn{request_path: path} = conn) do
    put_private(conn, :phauxth_error, "You have to be logged in to view #{path}")
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, _role) do
    put_private(conn, :phauxth_error, "You do not have permission to view #{path}")
  end
end
