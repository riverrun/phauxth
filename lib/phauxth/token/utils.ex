defmodule Phauxth.Token.Utils do
  @moduledoc """
  Utility functions to generate keys from a 'key source'.

  These functions are based on the key generation functions in the
  Phoenix.Token module.
  """

  alias Phauxth.Config
  alias Plug.Crypto.KeyGenerator

  @doc """
  Gets a key from a key source.

  A key source can be a conn struct, an endpoint, or a string.
  """
  @spec get_key(Plug.Conn.t() | atom | binary, keyword) :: binary
  def get_key(key_source, opts) do
    salt = Keyword.get(opts, :token_salt, Config.token_salt())
    key_source |> get_key_base() |> get_secret(salt, opts)
  end

  defp get_key_base(%Plug.Conn{secret_key_base: key_base}), do: key_base

  defp get_key_base(endpoint) when is_atom(endpoint),
    do: endpoint.config(:secret_key_base)

  defp get_key_base(string) when is_binary(string) and byte_size(string) >= 20,
    do: string

  defp get_secret(secret_key_base, salt, opts) do
    iterations = Keyword.get(opts, :key_iterations, 1000)
    length = Keyword.get(opts, :key_length, 32)
    digest = Keyword.get(opts, :key_digest, :sha256)
    key_opts = [iterations: iterations, length: length, digest: digest, cache: Plug.Keys]
    KeyGenerator.generate(secret_key_base, salt, key_opts)
  end
end
