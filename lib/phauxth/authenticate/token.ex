defmodule Phauxth.Authenticate.Token do
  @moduledoc """
  Base module for token authentication.

  This is `use`-d by Phauxth.TokenAuth, and it can also be used
  to produce a custom authentication module, as outlined below.

  ## Custom authentication modules

  The next sections give examples of extending this module to create
  custom authentication modules.

  ### Graphql authentication

  The following module is another example of how this Base module can
  be extended, this time to provide authentication for absinthe-elixir:

      defmodule AbsintheAuthenticate do
        use Phauxth.Authenticate.Base

        def set_user(user, conn) do
          put_private(conn, :absinthe, %{context: %{current_user: user}})
        end
      end

  And in the `router.ex` file, call this plug in the pipeline you
  want to authenticate.

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
  You can then use Phauxth.Token.verify, in the `user_socket.ex` file, to
  verify the token.
  """

  @doc """
  Gets the token from the authorization headers.
  """
  @callback get_token_user(list, Plug.Conn.t(), tuple) :: map | nil

  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Authenticate.Token

      use Phauxth.Authenticate.Base

      @impl Phauxth.Authenticate.Base
      def get_user(conn, opts) do
        conn |> get_req_header("authorization") |> get_token_user(conn, opts)
      end

      @impl Phauxth.Authenticate.Token
      def get_token_user([], _, _), do: {:error, "no token found"}

      def get_token_user(["Bearer " <> token | _], conn, opts) do
        get_token_user([token], conn, opts)
      end

      def get_token_user([token | _], conn, {max_age, user_context, opts}) do
        with {:ok, id} <- Phauxth.Token.verify(conn, token, max_age, opts),
             do: user_context.get(id)
      end

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
      defoverridable Phauxth.Authenticate.Token
    end
  end
end
