if Code.ensure_loaded?(Phoenix) do
  defmodule Phauxth.PhxToken do
    @moduledoc """
    Token implementation using Phoenix Token.
    """

    # WARNING!
    # ========
    #
    # This module will be removed before the the release of 2.0.0
    #
    # You will need to create a token module using the Phauxth.Token
    # behaviour in your app.
    # Then set the `token_module` value in the phauxth config to the
    # module you have created.

    @behaviour Phauxth.Token

    alias Phoenix.Token

    @max_age 14_400

    @impl true
    def sign(data, opts \\ []) do
      key_source = Application.get_env(:phauxth, :endpoint)
      salt = Application.get_env(:phauxth, :token_salt)
      Token.sign(key_source, salt, data, opts)
    end

    @impl true
    def verify(token, opts \\ []) do
      key_source = Application.get_env(:phauxth, :endpoint)
      salt = Application.get_env(:phauxth, :token_salt)
      Token.verify(key_source, salt, token, opts ++ [max_age: @max_age])
    end
  end
end
