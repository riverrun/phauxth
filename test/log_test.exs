defmodule Phauxth.LogTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  require Logger
  alias Phauxth.Log

  test "logs to console" do
    assert capture_log(fn ->
             Log.warn(%Log{user: "arrr@example.com", message: "bossman's arrived"})
           end) =~ ~s(user=arrr@example.com message="bossman's arrived")
  end

  test "logs default values" do
    assert capture_log(fn ->
             Log.warn(%Log{})
           end) =~ ~s(user=nil message="")
  end

  test "logs metadata" do
    assert capture_log(fn ->
             Log.warn(%Log{user: "arrr@example.com", meta: [{"error", "mmm"}]})
           end) =~ ~s(user=arrr@example.com message="" error=mmm)
  end

  test "logs to console for nil current_user" do
    assert capture_log(fn ->
             Log.warn(%Log{user: "arrr@example.com", message: "nil user"})
           end) =~ ~s(user=arrr@example.com message="nil user")
  end

  test "quotes values containing '='" do
    assert capture_log(fn ->
             Log.warn(%Log{message: "invalid query string"})
           end) =~ ~s(user=nil message="invalid query string")
  end

  test "does not print log if config log_level is false" do
    Application.put_env(:phauxth, :log_level, false)

    assert capture_log(fn ->
             Log.warn(%Log{user: "arrr@example.com", message: "nil user"})
           end) =~ ""
  after
    Application.put_env(:phauxth, :log_level, :info)
  end

  test "does not print log if level is lower than config log_level" do
    Application.put_env(:phauxth, :log_level, :warn)

    assert capture_log(fn ->
             Log.info(%Log{user: "arrr@example.com", message: "nil user"})
           end) =~ ""
  after
    Application.put_env(:phauxth, :log_level, :info)
  end
end
