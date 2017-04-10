defmodule Phauxth.Login.Utils do
  @moduledoc """
  Functions used when logging in.

  These functions are used by the Phauxth.Login and Phauxth.Otp
  modules, and they can also be used when creating custom
  login functions / modules.
  """

  import Plug.Conn
  alias Phauxth.{Config, Log}

  @doc """
  Prints out a log message and adds an `phauxth_user` or `phauxth_error`
  message to the conn.

  The first argument to the function should be `{:ok, user}`,
  `{:error, error_log}` or `{:error, error_log, error_msg}`.
  error_log refers to what will be reported in the logs,
  and error_msg will be what the end user sees. If you call this
  function without a custom error_msg, the default value of
  `Invalid credentials` will be used.
  """
  def report({:ok, user}, conn, user_id, ok_log) do
    Log.log(:info, Config.log_level, conn.request_path,
            %Log{user: user_id, message: ok_log})
    put_private(conn, :phauxth_user, Map.drop(user, Config.drop_user_keys))
  end
  def report({:error, error_log}, conn, user_id, _) do
    Log.log(:warn, Config.log_level, conn.request_path,
            %Log{user: user_id, message: error_log})
    put_private(conn, :phauxth_error, "Invalid credentials")
  end
  def report({:error, error_log, error_msg}, conn, user_id, _) do
    Log.log(:warn, Config.log_level, conn.request_path,
            %Log{user: user_id, message: error_log})
    put_private(conn, :phauxth_error, error_msg)
  end
end
