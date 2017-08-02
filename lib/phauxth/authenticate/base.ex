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

  ### Graphql authentication

  The following module is another example of how this Base module can
  be extended, this time to provide authentication for absinthe-elixir:

      defmodule AbsintheAuthenticate do

        use Phauxth.Authenticate.Base
        import Plug.Conn

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

  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @behaviour Plug

      import Plug.Conn
      alias Phauxth.{Config, Log, Token, Utils}

      @doc false
      def init(opts) do
        {Keyword.get(opts, :method, :session),
        Keyword.get(opts, :max_age, 24 * 60 * 60),
        Keyword.get(opts, :user_context, Utils.default_user_context())}
      end

      @doc false
      def call(conn, opts) do
        get_user(conn, opts) |> report |> set_user(conn)
      end

      @doc """
      Get the user based on the session id or token id.

      This function also calls the database to get user information.
      """
      def get_user(conn, {:session, _, user_context}) do
        with user_id when not is_nil(user_id) <- get_session(conn, :user_id),
          do: user_context.get(user_id)
      end
      def get_user(%Plug.Conn{req_headers: headers} = conn,
          {:token, max_age, user_context}) do
        with {_, token} <- List.keyfind(headers, "authorization", 0),
             {:ok, user_id} <- Token.verify(conn, token, max_age: max_age),
          do: user_context.get(user_id)
      end

      @doc """
      Log the result of the authentication and return the user struct or nil.
      """
      def report(%{} = user) do
        Log.info(%Log{user: user.id, message: "user authenticated"})
        Map.drop(user, Config.drop_user_keys)
      end
      def report({:error, message}) do
        Log.info(%Log{message: message}) && nil
      end
      def report(nil) do
        Log.info(%Log{}) && nil
      end

      @doc """
      Set the `current_user` variable.
      """
      def set_user(user, conn) do
        Plug.Conn.assign(conn, :current_user, user)
      end

      defoverridable [init: 1, call: 2, get_user: 2, report: 1, set_user: 2]
    end
  end
end
