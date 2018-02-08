defmodule Phauxth.Token do
  @moduledoc """
  Create api tokens.

  The data stored in the token is signed to prevent tampering
  but not encrypted. This means it is safe to store identification
  information (such as user IDs) but should not be used to store
  confidential information (such as credit card numbers).

  ## Arguments to sign/3 and verify/4

  The first argument to both `sign/3` and `verify/4` is the `key_source`,
  from which the function can extract the secret key base. This can be one of:

    * the module name of a Phoenix endpoint
    * a `Plug.Conn` struct
    * a `Phoenix.Socket` struct
    * a string, representing the secret key base itself
      * this string should be at least 20 randomly generated characters long

  The second argument to sign/3 is the data to be signed, which can be
  an integer or string identifying the user, or a map with the user
  parameters.

  The second argument to verify/4 is the token to be verified.

  The third argument to verify/4 is the `max_age` (maximum age), in seconds,
  of the token. The recommended maximum age depends on how the token is used.
  For example, the Phauxth.Confirm module sets the maximum age to 1200, which
  is 20 minutes, but the Phauxth.Authenticate module sets the maximum age to
  14_400, which is 4 hours.

  The third argument to sign/3, or the fourth argument to verify/4, is
  the `opts`, the key generator options.

  The key generator has three options:

    * `:key_iterations` - the number of iterations the key derivation function uses
      * the default is 1000
    * `:key_length` - the length of the key, in bytes
      * the default is 32
    * `:key_digest` - the hash algorithm that is used
      * the default is :sha256
    * `:token_salt` - the salt to be used when generating the secret key
      * the default is the value set in the config

  Note that the same key generator options should be used for signing
  and verifying tokens.
  """

  @type key_source :: module | Plug.Conn.t() | String.t()
  @type token_data :: map | String.t() | integer
  @type result :: {:ok, token_data} | {:error, String.t()}

  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier
  alias Phauxth.Config

  @doc """
  Sign the token.

  See the module documentation for more information.
  """
  @spec sign(key_source, token_data, list) :: String.t()
  def sign(key_source, data, opts \\ []) do
    %{"data" => data, "signed" => now()}
    |> Poison.encode!()
    |> MessageVerifier.sign(gen_secret(key_source, opts))
  end

  @doc """
  Verify the token.

  See the module documentation for more information.
  """
  @spec verify(key_source, String.t(), integer, list) :: result
  def verify(key_source, token, max_age, opts \\ [])

  def verify(key_source, token, max_age, opts) when is_binary(token) do
    MessageVerifier.verify(token, gen_secret(key_source, opts))
    |> get_token_data
    |> handle_verify(max_age)
  end

  def verify(_, _, _, _), do: {:error, "invalid token"}

  defp gen_secret(key_source, opts) do
    get_key_base(key_source) |> validate_secret |> run_kdf(opts)
  end

  defp get_key_base(%Plug.Conn{secret_key_base: key}), do: key
  defp get_key_base(%{endpoint: endpoint}), do: get_endpoint_key_base(endpoint)

  defp get_key_base(endpoint) when is_atom(endpoint) do
    get_endpoint_key_base(endpoint)
  end

  defp get_key_base(key) when is_binary(key), do: key

  defp get_endpoint_key_base(endpoint) do
    endpoint.config(:secret_key_base) ||
      raise """
      no :secret_key_base configuration found in #{inspect(endpoint)}.
      """
  end

  defp run_kdf(secret_key_base, opts) do
    token_salt = Keyword.get(opts, :token_salt, Config.token_salt())

    key_opts = [
      iterations: opts[:key_iterations] || 1000,
      length: validate_len(opts[:key_length]),
      digest: validate_digest(opts[:key_digest]),
      cache: Plug.Keys
    ]

    KeyGenerator.generate(secret_key_base, token_salt, key_opts)
  end

  defp get_token_data({:ok, message}), do: Poison.decode(message)
  defp get_token_data(:error), do: {:error, "invalid token"}

  defp handle_verify({:ok, %{"data" => data, "signed" => signed}}, max_age) do
    (signed + max_age < now() and {:error, "expired token"}) || {:ok, data}
  end

  defp handle_verify(_, _), do: {:error, "invalid token"}

  defp now, do: System.system_time(:second)

  defp validate_secret(nil) do
    raise ArgumentError, "The secret_key_base has not been set"
  end

  defp validate_secret(key) when byte_size(key) < 20 do
    raise ArgumentError, "The secret_key_base is too short. It should be at least 20 bytes long."
  end

  defp validate_secret(key), do: key

  defp validate_len(nil), do: 32

  defp validate_len(len) when len < 20 do
    raise ArgumentError, "The key_length is too short. It should be at least 20 bytes long."
  end

  defp validate_len(len), do: len

  defp validate_digest(nil), do: :sha256
  defp validate_digest(digest) when digest in [:sha256, :sha512], do: digest

  defp validate_digest(digest) do
    raise ArgumentError, "Phauxth.Token does not support #{digest}"
  end
end
