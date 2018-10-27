defmodule PhauxthWeb.Endpoint do
  def config(:secret_key_base), do: String.duplicate("abcdef0123456789", 8)
end

defmodule Phauxth.TestToken do
  @behaviour Phauxth.Token

  alias Phauxth.PhoenixToken, as: Token
  alias PhauxthWeb.Endpoint

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

defmodule Phauxth.PhoenixToken do
  # This module consists of the Phoenix.Token module
  # this is used for testing purposes.

  require Logger
  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier

  def sign(context, salt, data, opts \\ []) when is_binary(salt) do
    {signed_at_seconds, key_opts} = Keyword.pop(opts, :signed_at)
    signed_at_ms = if signed_at_seconds, do: trunc(signed_at_seconds * 1000), else: now_ms()
    secret = get_key_base(context) |> get_secret(salt, key_opts)

    %{data: data, signed: signed_at_ms}
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(secret)
  end

  def verify(context, salt, token, opts \\ [])

  def verify(context, salt, token, opts) when is_binary(salt) and is_binary(token) do
    secret = context |> get_key_base() |> get_secret(salt, opts)

    case MessageVerifier.verify(token, secret) do
      {:ok, message} ->
        %{data: data, signed: signed} = Plug.Crypto.safe_binary_to_term(message)

        if expired?(signed, opts[:max_age]) do
          {:error, :expired}
        else
          {:ok, data}
        end

      :error ->
        {:error, :invalid}
    end
  end

  def verify(_context, salt, nil, _opts) when is_binary(salt) do
    {:error, :missing}
  end

  defp get_key_base(%Plug.Conn{} = conn),
    do: conn |> Phoenix.Controller.endpoint_module() |> get_endpoint_key_base()

  defp get_key_base(%Phoenix.Socket{} = socket),
    do: get_endpoint_key_base(socket.endpoint)

  defp get_key_base(endpoint) when is_atom(endpoint),
    do: get_endpoint_key_base(endpoint)

  defp get_key_base(string) when is_binary(string) and byte_size(string) >= 20,
    do: string

  defp get_endpoint_key_base(endpoint) do
    endpoint.config(:secret_key_base) ||
      raise """
      no :secret_key_base configuration found in #{inspect(endpoint)}.
      Ensure your environment has the necessary mix configuration. For example:

          config :my_app, MyApp.Endpoint,
              secret_key_base: ...

      """
  end

  # Gathers configuration and generates the key secrets and signing secrets.
  defp get_secret(secret_key_base, salt, opts) do
    iterations = Keyword.get(opts, :key_iterations, 1000)
    length = Keyword.get(opts, :key_length, 32)
    digest = Keyword.get(opts, :key_digest, :sha256)
    key_opts = [iterations: iterations, length: length, digest: digest, cache: Plug.Keys]
    KeyGenerator.generate(secret_key_base, salt, key_opts)
  end

  defp expired?(_signed, :infinity), do: false

  defp expired?(_signed, nil) do
    # TODO v2: Default to 86400 on future releases.
    Logger.warn(
      ":max_age was not set on Phoenix.Token.verify/4. " <>
        "A max_age is recommended otherwise tokens are forever valid. " <>
        "Please set it to the amount of seconds the token is valid, " <>
        "such as 86400 (1 day), or :infinity if you really want this token to be valid forever"
    )

    false
  end

  defp expired?(signed, max_age_secs), do: signed + trunc(max_age_secs * 1000) < now_ms()

  defp now_ms, do: System.system_time(:millisecond)
end
