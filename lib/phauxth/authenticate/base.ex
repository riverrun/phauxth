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
          put_private(conn, :absinthe, %{context: %{current_user: user}})
        end
      end

  And in the `router.ex` file, call this plug in the pipeline you
  want to authenticate (setting the context to the app's endpoint).

      plug :api do
        plug AbsintheAuthenticate, context: MyApp.Web.Endpoint
      end

  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Phauxth.Utils
      import unquote(__MODULE__)

      @behaviour Plug

      @doc false
      def init(opts) do
        {Keyword.get(opts, :context),
        Keyword.get(opts, :max_age, 7 * 24 * 60 * 60),
        Keyword.get(opts, :user_data, default_user_data())}
      end

      @doc false
      def call(conn, {nil, _, user_data}) do
        check_session(conn, user_data) |> log_user |> set_user(conn)
      end
      def call(%Plug.Conn{req_headers: headers} = conn, opts) do
        check_headers(headers, opts) |> log_user |> set_user(conn)
      end

      @doc """
      Set the `current_user` variable.
      """
      def set_user(user, conn) do
        Plug.Conn.assign(conn, :current_user, user)
      end

      defoverridable [init: 1, call: 2, set_user: 2]
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
  def check_session(conn, user_data) do
    with id when not is_nil(id) <- get_session(conn, :user_id),
        do: user_data.get(id)
  end

  @doc """
  Check the headers for an authorization token.

  This function also calls the database to get user information.
  """
  def check_headers(headers, opts) do
    with {_, token} <- List.keyfind(headers, "authorization", 0),
        do: check_token(token, opts)
  end

  @doc """
  Check the authorization token.

  This function also calls the database to get user information.
  """
  def check_token(token, {context, max_age, user_data}) do
    with {:ok, user_id} <- Token.verify(context, "user auth", token, max_age: max_age),
        do: user_data.get(user_id)
  end

  @doc """
  Log the result of the authentication and return the user struct or nil.
  """
  def log_user(nil) do
    Log.info(%Log{}) && nil
  end
  def log_user({:error, msg}) do
    Log.info(%Log{message: "#{msg} token"}) && nil
  end
  def log_user(user) do
    Log.info(%Log{user: user.id, message: "User authenticated"})
    Map.drop(user, Config.drop_user_keys)
  end
end
