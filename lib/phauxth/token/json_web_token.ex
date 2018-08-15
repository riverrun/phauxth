if Code.ensure_loaded?(JsonWebToken) do
  defmodule Phauxth.JsonWebToken do
    @moduledoc """
    Token implementation using JsonWebToken.
    """

    @behaviour Phauxth.Token

    @impl true
    def sign(data, opts) do
      # add exp?
      JsonWebToken.sign(data, opts)
    end

    @impl true
    def verify(token, opts) do
      # add exp check?
      JsonWebToken.verify(token, opts)
    end
  end
end
