defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions.

  ## Example using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Phauxth.Authenticate

  """

  import Plug.Conn
  alias Phauxth.Config

  @behaviour Plug

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _) do
    get_session(conn, :user_id) |> add_user(conn)
  end

  defp add_user(nil, conn), do: assign(conn, :current_user, nil)
  defp add_user(id, conn) do
    Config.repo.get(Config.user_mod, id) |> set_current_user(conn)
  end

  defp set_current_user(nil, conn), do: assign(conn, :current_user, nil)
  defp set_current_user(user, conn) do
    user = Map.drop(user, Config.drop_user_keys)
    assign(conn, :current_user, user)
  end
end
