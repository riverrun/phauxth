defmodule Phauxth.TokenTest do
  use ExUnit.Case
  use Plug.Test
  alias Phauxth.Token

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key
    {:ok, %{conn: conn}}
  end

  test "fails on missing token", %{conn: conn} do
    assert Token.verify(conn, nil) == {:error, :missing}
  end

  test "fails on invalid token", %{conn: conn} do
    token = Token.sign(conn, 1)

    assert Token.verify(conn, token) == {:ok, 1}
    assert Token.verify(conn, "garbage") == {:error, :invalid}
  end

  test "supports max age in seconds", %{conn: conn} do
    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, max_age: 1000) == {:ok, 1}
    assert Token.verify(conn, token, max_age: -1000) == {:error, :expired}

    token = Token.sign(conn, 1)
    assert Token.verify(conn, token, max_age: 0.1) == {:ok, 1}
    :timer.sleep(150)
    assert Token.verify(conn, token, max_age: 0.1) == {:error, :expired}
  end

  test "passes options to key generator", %{conn: conn} do
    signed = Token.sign(conn, 1, key_iterations: 1)
    assert Token.verify(conn, signed, key_iterations: 1) == {:ok, 1}
    assert Token.verify(conn, signed, key_iterations: 2) == {:error, :invalid}
    signed = Token.sign(conn, 1, key_digest: :sha256)
    assert Token.verify(conn, signed, key_digest: :sha256) == {:ok, 1}
    assert Token.verify(conn, signed, key_digest: :sha512) == {:error, :invalid}
    signed = Token.sign(conn, 1, key_length: 32)
    assert Token.verify(conn, signed, key_length: 32) == {:ok, 1}
    assert Token.verify(conn, signed, key_length: 64) == {:error, :invalid}
  end

  test "raises an error when the key_length is too short", %{conn: conn} do
    assert_raise ArgumentError, fn -> Token.sign(conn, 1, key_length: 16) end
    assert_raise ArgumentError, fn -> Token.sign(conn, 1, key_length: 31) end
  end

end
