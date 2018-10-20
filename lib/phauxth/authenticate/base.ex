defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Base module for authentication.

  This is `use`-d by Phauxth.Authenticate and Phauxth.Remember, and it is also
  extended by Phauxth.Authenticate.Token.

  This module can also be used to produce a custom authentication module,
  as outlined below.

  ## Custom authentication modules

  The next section gives examples of extending this module to create
  custom authentication modules.

  ## Examples

  ### Authentication for use with Phoenix channels

  In this example, after adding the user struct to the current_user value,
  a Phoenix token (using Phauxth.PhxToken) is added to the conn.

      defmodule MyAppWeb.ChannelAuthenticate do
        use Phauxth.Authenticate.Base

        def set_user(nil, conn), do: assign(conn, :current_user, nil)

        def set_user(user, conn) do
          token = Phauxth.PhxToken.sign(%{"user_id" => user.email}, [])
          user |> super(conn) |> assign(:user_token, token)
        end
      end

  MyAppWeb.ChannelAuthenticate is called in the same way as Phauxth.Authenticate.
  You can then use Phauxth.PhxToken.verify, in the `user_socket.ex` file, to
  verify the token.
  """

  @type error_message :: {:error, String.t()}

  @doc """
  Gets the user based on the session or token data.

  In the default implementation, this function also retrieves user
  information using the `get_by` function defined in the `user_context`
  module.
  """
  @callback get_user(Plug.Conn.t(), map) :: map | error_message | nil

  @doc """
  Logs the result of the authentication and return the user struct or nil.
  """
  @callback report(map | error_message | nil, keyword) :: map | nil

  @doc """
  Sets the `current_user` variable.
  """
  @callback set_user(map | nil, Plug.Conn.t()) :: Plug.Conn.t()

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug
      @behaviour Phauxth.Authenticate.Base

      import Plug.Conn
      alias Phauxth.{Config, Log}

      @impl Plug
      def init(opts) do
        {user_context, opts} = Keyword.pop(opts, :user_context, Config.user_context())
        {log_meta, opts} = Keyword.pop(opts, :log_meta, [])
        %{user_context: user_context, log_meta: log_meta, opts: opts}
      end

      @impl Plug
      def call(conn, %{log_meta: log_meta} = options) do
        conn |> get_user(options) |> report(log_meta) |> set_user(conn)
      end

      @impl Phauxth.Authenticate.Base
      def get_user(conn, %{user_context: user_context}) do
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

      def report(nil, meta) do
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
