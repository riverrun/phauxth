defmodule Phauxth.TokenTest do
  use ExUnit.Case
  use Plug.Test
  alias Phauxth.Token

  @seconds_in_day 24 * 60 * 60

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

  test "supports signed_at in seconds", %{conn: conn} do
    day_ago_seconds = System.system_time(:second) - @seconds_in_day
    token = Token.sign(conn, 1, signed_at: day_ago_seconds)
    assert Token.verify(conn, token, max_age: @seconds_in_day + 1) == {:ok, 1}
    assert Token.verify(conn, token, max_age: @seconds_in_day - 1) == {:error, :expired}
  end

  test "max_age defaults to one day", %{conn: conn} do
    day_ago_seconds = System.system_time(:seconds) - @seconds_in_day
    token = Token.sign(conn, 1, signed_at: day_ago_seconds + 1)
    assert Token.verify(conn, token) == {:ok, 1}
    token = Token.sign(conn, 1, signed_at: day_ago_seconds - 1)
    assert Token.verify(conn, token) == {:error, :expired}
  end

  test "passes options to key generator", %{conn: conn} do
    signed1 = Token.sign(conn, 1, signed_at: 0, key_iterations: 1)
    signed2 = Token.sign(conn, 1, signed_at: 0, key_iterations: 2)
    assert signed1 != signed2
    signed1 = Token.sign(conn, 1, signed_at: 0, key_digest: :sha256)
    signed2 = Token.sign(conn, 1, signed_at: 0, key_digest: :sha512)
    assert signed1 != signed2
    signed1 = Token.sign(conn, 1, signed_at: 0, key_length: 16)
    signed2 = Token.sign(conn, 1, signed_at: 0, key_length: 32)
    assert signed1 != signed2
  end

end
