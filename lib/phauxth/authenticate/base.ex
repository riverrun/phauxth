defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Base module for authentication.

  This is `use`-d by Phauxth.Authenticate and Phauxth.Remember, and it is also
  extended by Phauxth.Authenticate.Session and Phauxth.Authenticate.Token.
  It can also be used to produce a custom authentication module, as outlined
  below.

  ## Custom authentication modules

  The next sections give examples of extending this module to create
  custom authentication modules.

  ## Examples

  ### Authentication for use with Phoenix channels

  In this example, after adding the user struct to the current_user value,
  a token is added (for use with Phoenix channels).

      defmodule MyAppWeb.ChannelAuthenticate do
        use Phauxth.Authenticate.Base

        def set_user(nil, conn), do: assign(conn, :current_user, nil)
        def set_user(user, conn) do
          token = Phauxth.Token.sign(conn, %{"user_id" => user.email})
          assign(conn, :current_user, user)
          |> assign(:user_token, token)
        end
      end

  MyAppWeb.ChannelAuthenticate is called in the same way as Phauxth.Authenticate.
  You can then use Phauxth.Token.verify, in the `user_socket.ex` file, to
  verify the token.
  """

  @doc """
  Get the user based on the session or token data.

  This function also calls the database to get user information.
  """
  @callback get_user(Plug.Conn.t(), tuple) :: map | {:error, String.t()} | nil

  @doc """
  Log the result of the authentication and return the user struct or nil.
  """
  @callback report(tuple, keyword) :: map | nil

  @doc """
  Set the `current_user` variable.
  """
  @callback set_user(map | nil, Plug.Conn.t()) :: Plug.Conn.t()

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug
      @behaviour Phauxth.Authenticate.Base

      import Plug.Conn
      alias Phauxth.{Config, Log, Utils}

      @impl Plug
      def init(opts) do
        {Keyword.get(opts, :user_context, Utils.default_user_context()),
         Keyword.get(opts, :log_meta, [])}
      end

      @impl Plug
      def call(conn, {opts, log_meta}) do
        conn |> get_user(opts) |> report(log_meta) |> set_user(conn)
      end

      @impl Phauxth.Authenticate.Base
      def get_user(conn, user_context) do
        with id when not is_nil(id) <- get_session(conn, :session_id),
             do: user_context.get_by(%{"session_id" => id})
      end

      @impl Phauxth.Authenticate.Base
      def report(%{} = user, meta) do
        Log.info(%Log{user: user.id, message: "user authenticated", meta: meta})
        Map.drop(user, Config.drop_user_keys())
      end

      def report({:error, message}, meta) do
        Log.info(%Log{message: message, meta: meta}) && nil
      end

      def report(none, meta) when none in [nil, []] do
        Log.info(%Log{message: "anonymous user", meta: meta}) && nil
      end

      @impl Phauxth.Authenticate.Base
      def set_user(user, conn) do
        assign(conn, :current_user, user)
      end

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
    end
  end
end
