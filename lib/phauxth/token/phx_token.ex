if Code.ensure_loaded?(Phoenix) do
  defmodule Phauxth.PhxToken do
    @moduledoc """
    Token implementation using Phoenix Token.
    """

    @behaviour Phauxth.Token

    alias Phauxth.Config
    alias Phoenix.Token

    @max_age 14_400

    @impl true
    def sign(data, opts) do
      key_source = Keyword.get(opts, :key_source, Config.endpoint())
      salt = Keyword.get(opts, :token_salt, Config.token_salt())
      Token.sign(key_source, salt, data, opts)
    end

    @impl true
    def verify(token, opts) do
      key_source = Keyword.get(opts, :key_source, Config.endpoint())
      salt = Keyword.get(opts, :token_salt, Config.token_salt())
      {max_age, opts} = Keyword.pop(opts, :max_age, @max_age)

      try do
        Token.verify(key_source, salt, token, opts ++ [max_age: max_age])
      rescue
        _error in ArgumentError ->
          {:error, :invalid}

        error ->
          reraise error, __STACKTRACE__
      end
    end
  end
end
