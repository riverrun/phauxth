defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Base module for authentication.

  This is used by Phauxth.Authenticate and Phauxth.Remember.
  It can also be used to produce a custom authentication module,
  as outlined below.

  ## Custom authentication modules

  The next sections give examples of extending this module to create
  custom authentication modules.

  ### Graphql authentication

  The following module is another example of how this Base module can
  be extended, this time to provide authentication for absinthe-elixir:

      defmodule AbsintheAuthenticate do
        use Phauxth.Authenticate.Base

        def set_user(user, conn) do
          put_private(conn, :absinthe, %{token: %{current_user: user}})
        end
      end

  And in the `router.ex` file, call this plug in the pipeline you
  want to authenticate (setting the method to :token).

      pipeline :api do
        plug :accepts, ["json"]
        plug AbsintheAuthenticate, method: :token
      end

  ### Authentication for use with Phoenix channels

  In this example, after adding the user struct to the current_user value,
  a token is added (for use with Phoenix channels).

      defmodule MyAppWeb.Authenticate do
        use Phauxth.Authenticate.Base

        def set_user(nil, conn), do: assign(conn, :current_user, nil)
        def set_user(user, conn) do
          token = Phauxth.Token.sign(conn, %{"user_id" => user.email})
          assign(conn, :current_user, user)
          |> assign(:user_token, token)
        end
      end

  MyAppWeb.Authenticate is called in the same way as Phauxth.Authenticate.

  Use Phauxth.Token.verify, in the `user_socket.ex` file, to verify the
  token.

  ### Custom session / token implementations

  This module uses Plug sessions or Phauxth tokens (based on Phoenix.Token)
  by default. To use custom sessions or tokens, you need to create your
  own custom Authenticate module and override the `check_session` or
  `check_token` function.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Plug.Conn
      alias Phauxth.{Config, Log, Token, Utils}

      @behaviour Plug

      @doc false
      def init(opts) do
        {{Keyword.get(opts, :method, :session),
          Keyword.get(opts, :max_age, 4 * 60 * 60),
          Keyword.get(opts, :user_context, Utils.default_user_context()), opts},
          Keyword.get(opts, :log_meta, [])}
      end

      @doc false
      def call(conn, {opts, log_meta}) do
        get_user(conn, opts) |> report(log_meta) |> set_user(conn)
      end

      @doc """
      Get the user based on the session id or token id.

      This function also calls the database to get user information.
      """
      def get_user(conn, {:session, max_age, user_context, _}) do
        with <<session_id::binary-size(17), user_id::binary>> <- check_session(conn),
             %{sessions: sessions} = user <- user_context.get(user_id),
             timestamp when is_integer(timestamp) <- Map.get(sessions, session_id),
          do: (timestamp + max_age) > System.system_time(:second) and
            user || {:error, "session expired"}
      end
      def get_user(%Plug.Conn{req_headers: headers} = conn,
          {:token, max_age, user_context, opts}) do
        with {_, token} <- List.keyfind(headers, "authorization", 0),
             {:ok, user_id} <- check_token(conn, token, max_age, opts),
          do: user_context.get(user_id)
      end

      @doc """
      Check the session for the current user.
      """
      def check_session(conn) do
        get_session(conn, :phauxth_session_id)
      end

      @doc """
      Check the token for the current user.
      """
      def check_token(conn, token, max_age, opts) do
        Token.verify(conn, token, max_age, opts)
      end

      @doc """
      Log the result of the authentication and return the user struct or nil.
      """
      def report(%{} = user, meta) do
        Log.info(%Log{user: user.id, message: "user authenticated", meta: meta})
        Map.drop(user, Config.drop_user_keys)
      end
      def report({:error, message}, meta) do
        Log.info(%Log{message: message, meta: meta}) && nil
      end
      def report(nil, meta) do
        Log.info(%Log{message: "anonymous user", meta: meta}) && nil
      end

      @doc """
      Set the `current_user` variable.
      """
      def set_user(user, conn) do
        assign(conn, :current_user, user)
      end

      defoverridable [init: 1, call: 2, get_user: 2, check_session: 1,
                      check_token: 4, report: 2, set_user: 2]
    end
  end
end
