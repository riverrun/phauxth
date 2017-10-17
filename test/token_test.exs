defmodule Phauxth.TokenTest do
  use ExUnit.Case
  use Plug.Test
  alias Phauxth.Token

  @max_age 86_400

  defmodule TokenEndpoint do
    def config(:secret_key_base), do: String.duplicate("abcdef0123456789", 8)
  end

  defmodule ShortKeyEndpoint do
    def config(:secret_key_base), do: "abcdef0123456789"
  end

  defmodule OtherKeyEndpoint do
    def config(:secret_key_base), do: String.duplicate("0123456789abcdef", 8)
  end

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key
    {:ok, %{conn: conn}}
  end

  test "can use endpoint and / or conn to sign and verify", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, @max_age) == {:ok, 1}
    assert Token.verify(TokenEndpoint, token, @max_age) == {:ok, 1}
    token = Token.sign(TokenEndpoint, 10)
    assert Token.verify(TokenEndpoint, token, @max_age) == {:ok, 10}
    assert Token.verify(conn, token, @max_age) == {:ok, 10}
  end

  test "fails on invalid token", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, @max_age) == {:ok, 1}
    assert Token.verify(conn, "garbage", @max_age) == {:error, "invalid token"}
  end

  test "fails when signed with wrong key" do
    token = Token.sign(TokenEndpoint, 1)
    assert Token.verify(TokenEndpoint, token, @max_age) == {:ok, 1}
    assert Token.verify(OtherKeyEndpoint, token, @max_age) == {:error, "invalid token"}
  end

  test "max age is checked", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, 1000) == {:ok, 1}
    assert Token.verify(conn, token, -1000) == {:error, "expired token"}

    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, 0) == {:ok, 1}
    :timer.sleep(1000)
    assert Token.verify(conn, token, 0) == {:error, "expired token"}
  end

  test "passes options to key generator", %{conn: conn} do
    signed = Token.sign(conn, 1, key_iterations: 1)
    assert Token.verify(conn, signed, @max_age, key_iterations: 1) == {:ok, 1}
    assert Token.verify(conn, signed, @max_age, key_iterations: 2) == {:error, "invalid token"}
    signed = Token.sign(conn, 1, key_digest: :sha256)
    assert Token.verify(conn, signed, @max_age, key_digest: :sha256) == {:ok, 1}
    assert Token.verify(conn, signed, @max_age, key_digest: :sha512) == {:error, "invalid token"}
    signed = Token.sign(conn, 1, key_length: 32)
    assert Token.verify(conn, signed, @max_age, key_length: 32) == {:ok, 1}
    assert Token.verify(conn, signed, @max_age, key_length: 64) == {:error, "invalid token"}
  end

  test "raises when the secret_key_base is too short", %{conn: conn} do
    conn = Phauxth.SessionHelper.add_key(conn, "abcdef0123456789")
    assert_raise ArgumentError, fn -> Token.sign(conn, 1) end
  end

  test "raises when the secret_key_base is too short when signing with endpoint" do
    assert_raise ArgumentError, fn -> Token.sign(ShortKeyEndpoint, 1) end
  end

  test "raises when the key_length is too short", %{conn: conn} do
    assert_raise ArgumentError, fn -> Token.sign(conn, 1, key_length: 16) end
    assert_raise ArgumentError, fn -> Token.sign(conn, 1, key_length: 19) end
  end

  test "raises when a weak key digest is set", %{conn: conn} do
    assert_raise ArgumentError, "Phauxth.Token does not support md5", fn ->
      Token.sign(conn, 1, key_digest: :md5)
    end
    assert_raise ArgumentError, "Phauxth.Token does not support sha", fn ->
      Token.sign(conn, 1, key_digest: :sha)
    end
  end
end
