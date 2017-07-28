defmodule Phauxth.Token do
  @moduledoc """
  Api token based on the Phoenix token implementation.
  """

  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier
  alias Phauxth.Config

  @max_age 86_400

  def sign(conn, data, opts \\ []) do
    {signed_at_seconds, key_opts} = Keyword.pop(opts, :signed_at)
    signed_at_ms = if signed_at_seconds, do: trunc(signed_at_seconds * 1000), else: now_ms()
    secret = get_key_base(conn) |> get_secret(key_opts)

    %{data: data, signed: signed_at_ms}
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(secret)
  end

  def verify(conn, token, opts \\ [])
  def verify(conn, token, opts) when is_binary(token) do
    secret = get_key_base(conn) |> get_secret(opts)
    max_age_ms = trunc(Keyword.get(opts, :max_age, @max_age) * 1000)

    case MessageVerifier.verify(token, secret) do
      {:ok, message} ->
        %{data: data, signed: signed} = Plug.Crypto.safe_binary_to_term(message)

        if (signed + max_age_ms) < now_ms() do
          {:error, :expired}
        else
          {:ok, data}
        end
      :error ->
        {:error, :invalid}
    end
  end
  def verify(_conn, nil, _opts), do: {:error, :missing}

  defp get_key_base(conn) do
    conn.secret_key_base || raise """
    the secret_key_base has not been set
    """
  end

  defp get_secret(secret_key_base, opts) do
    iterations = Keyword.get(opts, :key_iterations, 1000)
    length = Keyword.get(opts, :key_length, 32)
    digest = Keyword.get(opts, :key_digest, :sha256)
    key_opts = [iterations: iterations,
                length: length,
                digest: digest,
                cache: Plug.Keys]
    KeyGenerator.generate(secret_key_base, Config.token_salt, key_opts)
  end

  defp now_ms, do: System.system_time(:millisecond)
end
