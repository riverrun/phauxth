defmodule Phauxth.Authenticate.Utils do
  @moduledoc """
  """

  import Plug.Conn
  alias Phoenix.Token
  alias Phauxth.Config

  @doc """
  """
  def check_session(conn) do
    with id when not is_nil(id) <- get_session(conn, :user_id),
        do: Config.repo.get(Config.user_mod, id)
  end

  @doc """
  """
  def check_headers(headers, context, max_age) do
    with {_, token} <- List.keyfind(headers, "authorization", 0),
        do: check_token(token, context, max_age)
  end

  @doc """
  """
  def check_token(token, context, max_age) do
    with {:ok, user_id} <- Token.verify(context, "user auth", token, max_age: max_age),
        do: Config.repo.get(Config.user_mod, user_id)
  end

  @doc """
  """
  def set_current_user(nil, conn), do: assign(conn, :current_user, nil)
  def set_current_user({:error, _}, conn), do: assign(conn, :current_user, nil)
  def set_current_user(user, conn) do
    user = Map.drop(user, Config.drop_user_keys)
    assign(conn, :current_user, user)
  end
end
