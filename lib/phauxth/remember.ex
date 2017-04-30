defmodule Phauxth.Remember do
  @moduledoc """
  Remember me Plug using Phoenix Token.

  ## Options

  There are two options:

    * context - the context to use when using Phoenix token
      * in most cases, this will be the name of the endpoint you are using
      * see the documentation for Phoenix.Token for more information
    * max_age - the length of the validity of the token
      * the default is one week
  """

  use Phauxth.Authenticate.Base, max_age: 7 * 24 * 60 * 60

  def call(%Plug.Conn{req_cookies: %{"remember_me" => token}} = conn, {context, max_age}) do
    if conn.assigns[:current_user] do
      conn
    else
      check_token(token, context || conn, max_age) |> set_current_user(conn)
    end
  end
  def call(conn, _), do: conn
end
