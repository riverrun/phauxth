defmodule Phauxth.Remember do
  @moduledoc """
  Remember me Plug using Phoenix Token.
  """

  use Phauxth.Authenticate.Base

  def call(%Plug.Conn{req_cookies: %{"remember_me" => token}} = conn, {context, max_age}) do
    if conn.assigns[:current_user] do
      conn
    else
      check_token(token, context, max_age) |> set_current_user(conn)
    end
  end
  def call(conn, _), do: conn
end
