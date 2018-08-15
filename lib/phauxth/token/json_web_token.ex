if Code.ensure_loaded?(JsonWebToken) do
  defmodule Phauxth.JsonWebToken do
    @moduledoc """
    Token implementation using JsonWebToken.

    ADD INSTRUCTIONS FOR SIGNING
    """

    @behaviour Phauxth.Token

    alias Phauxth.Config
    alias Phauxth.Token.Utils

    @impl true
    def verify(token, opts) do
      key_source = Keyword.get(opts, :key_source, Config.endpoint())
      key = Utils.get_key(key_source, opts)
      # add exp check?
      # might need to check for alg as well?
      JsonWebToken.verify(token, %{key: key})
    end
  end
end
