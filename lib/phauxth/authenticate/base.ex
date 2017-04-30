defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Base module for authentication.

  This is used by Phauxth.Authenticate and Phauxth.Remember.
  It can also be used to produce a custom authentication module,
  as outlined below.

  ## Custom authentication modules

  One example of a custom authentication module is provided by the
  Phauxth.Remember module, which uses this base module to provide the
  'remember me' functionality.
  """

  @doc false
  defmacro __using__(options) do
    quote do
      @behaviour Plug
      @max_age unquote(options)[:max_age] || 24 * 60 * 60

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        {Keyword.get(opts, :context),
        Keyword.get(opts, :max_age, @max_age)}
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
  alias Phauxth.{Config, Log}

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
  def set_current_user(nil, conn), do: report_nil_user(conn, "no user")
  def set_current_user({:error, msg}, conn), do: report_nil_user(conn, "#{msg} token")
  def set_current_user(user, conn) do
    Log.log(:info, Config.log_level, conn.request_path,
            %Log{user: user.id, message: "User authenticated"})
    user = Map.drop(user, Config.drop_user_keys)
    assign(conn, :current_user, user)
  end

  defp report_nil_user(conn, error_msg) do
    Log.log(:info, Config.log_level, conn.request_path,
            %Log{user: "none", message: error_msg})
    assign(conn, :current_user, nil)
  end
end
