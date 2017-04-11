defmodule Phauxth.AbsintheAuthenticate do
  @moduledoc """
  Authentication module for absinthe-graphql.
  """

  use Phauxth.Authenticate.Base
  import Plug.Conn
  alias Phauxth.Config

  def call(%Plug.Conn{req_headers: headers} = conn, {context, max_age}) do
    check_headers(headers, context, max_age) |> set_absinthe_user(conn)
  end
  def call(conn, _), do: conn

  defp set_absinthe_user(nil, conn), do: conn
  defp set_absinthe_user({:error, _}, conn), do: conn
  defp set_absinthe_user(user, conn) do
    user = Map.drop(user, Config.drop_user_keys)
    put_private(conn, :absinthe, %{context: %{current_user: user}})
  end
end
