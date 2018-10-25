defmodule Phauxth.Authenticate.Token do
  @moduledoc """
  Base module for token authentication.

  This is `use`-d by Phauxth.AuthenticateToken, and it can also be used
  to produce a custom token authentication module, as outlined below.

  ## Custom token authentication modules

  The next sections give examples of extending this module to create
  custom authentication modules.

  ### Token authentication with token stored in a cookie

  This module will retrieve the token from a cookie, instead of from
  the headers:

      defmodule Phauxth.AuthenticateTokenCookie do
        use Phauxth.Authenticate.Token

        @impl true
        def authenticate(%Plug.Conn{req_cookies: %{"access_token" => token}}, opts) do
          verify_token(token, opts)
        end
      end

  And in the `router.ex` file, call this plug in the pipeline you
  want to authenticate.

      pipeline :api do
        plug :accepts, ["json"]
        plug AuthenticateTokenCookie
      end

  ### GraphQL authentication

  The following module is an example of how Phauxth.Authenticate.Token
  module can be extended, this time to provide authentication for
  absinthe-elixir:

      defmodule AbsintheAuthenticate do
        use Phauxth.Authenticate.Token

        @impl true
        def set_user(user, conn) do
          Absinthe.Plug.put_options(conn, context: %{current_user: user})
        end
      end

  As in the above example, in the `router.ex` file, call this plug
  in the pipeline you want to authenticate.
  """

  @doc """
  Gets the token from the authorization headers.
  """
  @callback get_token(list, keyword) :: map | nil

  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Authenticate.Token

      use Phauxth.Authenticate.Base

      alias Phauxth.Config

      @impl Phauxth.Authenticate.Base
      def authenticate(conn, opts) do
        conn |> get_req_header("authorization") |> get_token(opts)
      end

      @impl Phauxth.Authenticate.Token
      def get_token([], _), do: {:error, "no token found"}
      def get_token(["Bearer " <> token | _], opts), do: verify_token(token, opts)
      def get_token([token | _], opts), do: verify_token(token, opts)

      defp verify_token(token, opts) do
        token |> Config.token_module().verify(opts) |> get_user()
      end

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
      defoverridable Phauxth.Authenticate.Token
    end
  end
end
