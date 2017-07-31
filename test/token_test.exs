defmodule Phauxth.TokenTest do
  use ExUnit.Case
  use Plug.Test
  alias Phauxth.Token

  defmodule TokenEndpoint do
    def config(:secret_key_base), do: String.duplicate("abcdef0123456789", 8)
  end

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key
    {:ok, %{conn: conn}}
  end

  test "can use endpoint and / or conn to sign and verify", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token) == {:ok, 1}
    assert Token.verify(TokenEndpoint, token) == {:ok, 1}
    token = Token.sign(TokenEndpoint, 10)
    assert Token.verify(TokenEndpoint, token) == {:ok, 10}
    assert Token.verify(conn, token) == {:ok, 10}
  end

  test "fails on missing token", %{conn: conn} do
    assert Token.verify(conn, nil) == {:error, "missing token"}
  end

  test "fails on invalid token", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token) == {:ok, 1}
    assert Token.verify(conn, "garbage") == {:error, "invalid token"}
  end

  test "supports max age in seconds", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, max_age: 1000) == {:ok, 1}
    assert Token.verify(conn, token, max_age: -1000) == {:error, "expired token"}

    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, max_age: 0.1) == {:ok, 1}
    :timer.sleep(150)
    assert Token.verify(conn, token, max_age: 0.1) == {:error, "expired token"}
  end

  test "passes options to key generator", %{conn: conn} do
    signed = Token.sign(conn, 1, key_iterations: 1)
    assert Token.verify(conn, signed, key_iterations: 1) == {:ok, 1}
    assert Token.verify(conn, signed, key_iterations: 2) == {:error, "invalid token"}
    signed = Token.sign(conn, 1, key_digest: :sha256)
    assert Token.verify(conn, signed, key_digest: :sha256) == {:ok, 1}
    assert Token.verify(conn, signed, key_digest: :sha512) == {:error, "invalid token"}
    signed = Token.sign(conn, 1, key_length: 32)
    assert Token.verify(conn, signed, key_length: 32) == {:ok, 1}
    assert Token.verify(conn, signed, key_length: 64) == {:error, "invalid token"}
  end

  test "raises an error when the secret_key_base is too short", %{conn: conn} do
    conn = Phauxth.SessionHelper.add_key(conn, "abcdef0123456789")
    assert_raise ArgumentError, fn -> Token.sign(conn, 1) end
    assert_raise ArgumentError, fn -> Token.sign(conn, 1) end
  end

  test "raises an error when the key_length is too short", %{conn: conn} do
    assert_raise ArgumentError, fn -> Token.sign(conn, 1, key_length: 16) end
    assert_raise ArgumentError, fn -> Token.sign(conn, 1, key_length: 19) end
  end

end
