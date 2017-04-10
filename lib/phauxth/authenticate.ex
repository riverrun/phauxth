defmodule Phauxth.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions or Phoenix token.

  ## Example using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add a context:

      plug Phauxth.Authenticate, context: MyApp.Web.Endpoint

  """

  import Plug.Conn
  alias Phoenix.Token
  alias Phauxth.Config

  @behaviour Plug

  @doc false
  def init(opts) do
    {Keyword.get(opts, :context),
    Keyword.get(opts, :max_age, 24 * 60 * 60)}
  end

  @doc false
  def call(conn, {nil, _}) do
    with id when not is_nil(id) <- get_session(conn, :user_id) do
      Config.repo.get(Config.user_mod, id) |> set_current_user(conn)
    else
      nil -> assign(conn, :current_user, nil)
    end
  end
  def call(%Plug.Conn{req_headers: headers} = conn, {context, max_age}) do
    with {_, token} <- List.keyfind(headers, "authorization", 0),
         {:ok, user_id} <- Token.verify(context, "user auth", token, max_age: max_age) do
      Config.repo.get(Config.user_mod, user_id) |> set_current_user(conn)
    else
      nil -> assign(conn, :current_user, nil)
      {:error, _} -> assign(conn, :current_user, nil)
    end
  end
  def call(conn, _) do
    assign(conn, :current_user, nil)
  end

  defp set_current_user(nil, conn), do: assign(conn, :current_user, nil)
  defp set_current_user(user, conn) do
    user = Map.drop(user, Config.drop_user_keys)
    assign(conn, :current_user, user)
  end
end
