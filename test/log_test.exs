defmodule Phauxth.LogTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  require Logger
  alias Phauxth.Log

  @user %{id: 1, email: "arrr@mail.com"}

  test "logs to console" do
    assert capture_log(fn ->
      conn = conn(:get, "/admin") |> assign(:current_user, @user)
      Log.warn(conn, %Log{user: "arrr@mail.com",
        message: "bossman's arrived",
        meta: [{"current_user_id", Log.current_user_id(conn.assigns)}]})
    end) =~ ~s(path=/admin user=arrr@mail.com message="bossman's arrived" current_user_id=1)
  end

  test "logs to console for nil current_user" do
    assert capture_log(fn ->
      conn = conn(:get, "/login") |> assign(:current_user, nil)
      Log.warn(conn, %Log{user: "arrr@mail.com",
        message: "failed login"})
    end) =~ ~s(path=/login user=arrr@mail.com message="failed login")
  end

  test "quotes values containing '='" do
    assert capture_log(fn ->
      conn = conn(:get, "/admin")
      Log.warn(conn, %Log{message: "invalid query string",
        meta: [{"query", "email=wrong%40mail.com"}]})
    end) =~ ~s(path=/admin user=nil message="invalid query string" query="email=wrong%40mail.com")
  end

  test "does not print log if config log_level is false" do
    Application.put_env(:phauxth, :log_level, false)
    assert capture_log(fn ->
      conn = conn(:get, "/login")
      Log.warn(conn, %Log{user: "arrr@mail.com",
        message: "failed login"})
    end) =~ ""
    after
    Application.put_env(:phauxth, :log_level, :info)
  end

  test "does not print log if level is lower than config log_level" do
    Application.put_env(:phauxth, :log_level, :warn)
    assert capture_log(fn ->
      conn = conn(:get, "/login")
      Log.info(conn, %Log{user: "arrr@mail.com",
        message: "failed login"})
    end) =~ ""
    after
    Application.put_env(:phauxth, :log_level, :info)
  end

end
