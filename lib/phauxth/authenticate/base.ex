defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Base module for authentication.

  This is used by Phauxth.Authenticate and Phauxth.AbsintheAuthenticate.
  It can also be used to produce a custom authentication module.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        {Keyword.get(opts, :context),
        Keyword.get(opts, :max_age, 24 * 60 * 60)}
      end

      @doc false
      def call(conn, {nil, _}) do
        check_session(conn) |> set_current_user(conn)
      end
      def call(%Plug.Conn{req_headers: headers} = conn, {context, max_age}) do
        check_headers(headers, context, max_age) |> set_current_user(conn)
      end

      defoverridable [init: 1, call: 2]
    end
  end

  import Plug.Conn
  alias Phoenix.Token
  alias Phauxth.Config

  @doc """
  Check the conn to see if the user is registered in the current
  session.

  This function also calls the database to get user information.
  """
  def check_session(conn) do
    with id when not is_nil(id) <- get_session(conn, :user_id),
        do: Config.repo.get(Config.user_mod, id)
  end

  @doc """
  Check the headers for an authorization token.

  This function also calls the database to get user information.
  """
  def check_headers(headers, context, max_age) do
    with {_, token} <- List.keyfind(headers, "authorization", 0),
        do: check_token(token, context, max_age)
  end

  @doc """
  Check the authorization token.

  This function also calls the database to get user information.
  """
  def check_token(token, context, max_age) do
    with {:ok, user_id} <- Token.verify(context, "user auth", token, max_age: max_age),
        do: Config.repo.get(Config.user_mod, user_id)
  end

  @doc """
  Set the `current_user` value.
  """
  def set_current_user(nil, conn), do: assign(conn, :current_user, nil)
  def set_current_user({:error, _}, conn), do: assign(conn, :current_user, nil)
  def set_current_user(user, conn) do
    user = Map.drop(user, Config.drop_user_keys)
    assign(conn, :current_user, user)
  end
end
