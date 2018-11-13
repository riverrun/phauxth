defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Base module for authentication.

  This is `use`-d by Phauxth.Authenticate and Phauxth.Remember, and it is
  extended by Phauxth.Authenticate.Token.

  This module can also be used to produce a custom authentication module,
  as outlined below.

  ## Custom authentication modules

  The next section gives examples of extending this module to create
  custom authentication modules.

  ## Examples

  ### Authentication for use with Phoenix channels

  In this example, after adding the user struct to the current_user value,
  a token is added to the conn.

      defmodule MyAppWeb.ChannelAuthenticate do
        use Phauxth.Authenticate.Base

        def set_user(nil, conn), do: assign(conn, :current_user, nil)

        def set_user(user, conn) do
          token = MyAppWeb.Token.sign(%{"user_id" => user.email})
          user |> super(conn) |> assign(:user_token, token)
        end
      end

  MyAppWeb.ChannelAuthenticate is called in the same way as Phauxth.Authenticate.

  You can then use MyAppWeb.Token.verify, in the `user_socket.ex` file, to
  verify the token - see the documentation for Phauxth.Token for information
  about how to create the MyAppWeb.Token module.
  """

  @type ok_or_error :: {:ok, map} | {:error, String.t() | atom}

  @doc """
  Gets the user based on the session or token data.

  In the default implementation, this function also retrieves user
  information using the `get_by` function defined in the `user_context`
  module.
  """
  @callback authenticate(Plug.Conn.t(), module, keyword) :: ok_or_error

  @doc """
  Logs the result of the authentication and returns the user struct or nil.
  """
  @callback report(ok_or_error, keyword) :: map | nil

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
        {Keyword.get(opts, :user_context, Config.user_context()),
         Keyword.get(opts, :log_meta, []), opts}
      end

      @impl Plug
      def call(conn, {user_context, log_meta, opts}) do
        conn
        |> authenticate(user_context, opts)
        |> report(log_meta)
        |> set_user(conn)
      end

      @impl Phauxth.Authenticate.Base
      def authenticate(conn, user_context, _opts) do
        case get_session(conn, :phauxth_session_id) do
          nil -> {:error, "anonymous user"}
          session_id -> get_user({:ok, %{"session_id" => session_id}}, user_context)
        end
      end

      defp get_user({:ok, data}, user_context) do
        case user_context.get_by(data) do
          nil -> {:error, "no user found"}
          user -> {:ok, user}
        end
      end

      defp get_user({:error, message}, _), do: {:error, message}

      @impl Phauxth.Authenticate.Base
      def report({:ok, user}, meta) do
        Log.info(%Log{user: user.id, message: "user authenticated", meta: meta})
        Map.drop(user, Config.drop_user_keys())
      end

      def report({:error, message}, meta) do
        Log.info(%Log{message: message, meta: meta})
        nil
      end

      @impl Phauxth.Authenticate.Base
      def set_user(user, conn), do: assign(conn, :current_user, user)

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
    end
  end
end
