defmodule Phauxth.Authenticate.Token do
  @moduledoc """
  Base module for token authentication.

  This is `use`-d by Phauxth.TokenAuth, and it can also be used
  to produce a custom authentication module, as outlined below.

  ## Custom token authentication modules

  The next sections give examples of extending this module to create
  custom authentication modules.

  ### Graphql authentication

  The following module is an example of how Phauxth.Authenticate.Token
  module can be extended, this time to provide authentication for
  absinthe-elixir:

      defmodule AbsintheAuthenticate do
        use Phauxth.Authenticate.Token

        def set_user(user, conn) do
          put_private(conn, :absinthe, %{context: %{current_user: user}})
        end
      end

  And in the `router.ex` file, call this plug in the pipeline you
  want to authenticate.

      pipeline :api do
        plug :accepts, ["json"]
        plug AbsintheAuthenticat
      end

  """

  @doc """
  Gets the token from the authorization headers.
  """
  @callback get_token_user(list, Plug.Conn.t(), tuple) :: map | nil

  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Authenticate.Token

      use Phauxth.Authenticate.Base

      alias Phauxth.Utils

      @impl Plug
      def init(opts) do
        {{Keyword.get(opts, :max_age, 4 * 60 * 60),
          Keyword.get(opts, :user_context, Utils.default_user_context()), opts},
         Keyword.get(opts, :log_meta, [])}
      end

      @impl Phauxth.Authenticate.Base
      def get_user(conn, opts) do
        conn |> get_req_header("authorization") |> get_token_user(conn, opts)
      end

      @impl Phauxth.Authenticate.Token
      def get_token_user([], _, _), do: {:error, "no token found"}

      def get_token_user(["Bearer " <> token | _], conn, opts) do
        verify_token(token, conn, opts)
      end

      def get_token_user([token | _], conn, opts) do
        verify_token(token, conn, opts)
      end

      defp verify_token(token, conn, {max_age, user_context, opts}) do
        with {:ok, data} <- Phauxth.Token.verify(conn, token, max_age, opts),
             do: user_context.get_by(data)
      end

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
      defoverridable Phauxth.Authenticate.Token
    end
  end
end
