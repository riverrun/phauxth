defmodule Phauxth.Token do
  @moduledoc """
  Behaviour for signing and verifying tokens.

  If you are using Phauxth for token authentication, email confirmation
  or password resetting, you will need to define a module in your app
  that uses this behaviour.

  ## Examples

  The following is an example token module using Phoenix tokens.

      defmodule MyAppWeb.Auth.Token do
        @behaviour Phauxth.Token

        alias Phoenix.Token
        alias MyAppWeb.Endpoint

        @max_age 14_400
        @token_salt "JaKgaBf2"

        @impl true
        def sign(data, opts \\ []) do
          Token.sign(Endpoint, @token_salt, data, opts)
        end

        @impl true
        def verify(token, opts \\ []) do
          Token.verify(Endpoint, @token_salt, token, opts ++ [max_age: @max_age])
        end
      end

  """

  @type data :: map | keyword | binary | integer
  @type opts :: keyword

  @doc """
  Signs a token.
  """
  @callback sign(data, opts) :: binary

  @doc """
  Verifies a token.
  """
  @callback verify(binary, opts) :: {:ok, map} | {:error, atom | binary}
end
