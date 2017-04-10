defmodule Phauxth.Remember do
  @moduledoc """
  """

  import Plug.Conn
  alias Phoenix.Token

  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{req_headers: headers} = conn, {context, max_age}) do
    check(headers, context, max_age) |> set_current_user(conn)
  end

  def check(headers, context, max_age) do
    with {_, token} <- List.keyfind(headers, "authorization", 0),
        {:ok, user_id} <- Token.verify(context, "user auth", token, max_age: max_age),
        do: Config.repo.get(Config.user_mod, user_id)
  end

  defp set_current_user(nil, conn), do: assign(conn, :current_user, nil)
  defp set_current_user({:error, _}, conn), do: assign(conn, :current_user, nil)
  defp set_current_user(user, conn) do
    user = Map.drop(user, Config.drop_user_keys)
    assign(conn, :current_user, user)
  end
end
