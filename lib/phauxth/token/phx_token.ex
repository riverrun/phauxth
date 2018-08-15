if Code.ensure_loaded?(Phoenix) do
  defmodule Phauxth.PhxToken do
    @moduledoc """
    Token implementation using Phoenix Token.

    ADD INSTRUCTIONS FOR SIGNING
    """

    @behaviour Phauxth.Token

    alias Phauxth.Config
    alias Phoenix.Token

    @impl true
    def verify(token, opts) do
      key_source = Keyword.get(opts, :key_source, Config.endpoint())
      salt = Keyword.get(opts, :token_salt, Config.token_salt())
      Token.verify(key_source, salt, token, opts ++ [max_age: 14_400])
    end
  end
end
