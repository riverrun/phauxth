defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.

  This module is used by Phauxth.Login, and it can also be used to
  create customized Plugs to handle login.

  ## Custom login modules

  The init/1, call/2 and check_pass/2 functions can all be overridden.

  One example of a custom login module is provided by the
  Phauxth.Confirm.Login module, which extends this base module by
  adding a check to see if the user has been successfully confirmed.

  ### Custom module for password authentication

  You can use a different module to handle password authentication by
  overriding the check_pass/2 function.

  ### Custom value for the hash name (in the database)

  Overriding the check_pass/2 function will also let you use a different
  value to refer to the password hash (:password_hash is the default).
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)
      alias Comeonin.Bcrypt
      alias Phauxth.Config

      @doc false
      def init(opts) do
        uniq = Keyword.get(opts, :identifier, :email)
        user_params = if is_atom(uniq), do: to_string(uniq), else: "email"
        {uniq, user_params}
      end

      @doc false
      def call(%Plug.Conn{params: %{"session" => params}} = conn,
          {uniq, user_params}) when is_atom(uniq) do
        %{^user_params => user_id, "password" => password} = params
        check_user_pass(uniq, user_id, password)
        |> report(conn, user_id, "successful login")
      end
      def call(_conn, _), do: raise ArgumentError, "identifier should be an atom"

      @doc false
      def check_user_pass(uniq, user_id, password) do
        Config.repo.get_by(Config.user_mod, [{uniq, user_id}])
        |> check_pass(password)
      end

      @doc false
      def check_pass(nil, _) do
        Bcrypt.dummy_checkpw
        {:error, "invalid user-identifier"}
      end
      def check_pass(%{password_hash: hash} = user, password) do
        Bcrypt.checkpw(password, hash) and
        {:ok, user} || {:error, "invalid password"}
      end

      defoverridable [init: 1, call: 2, check_user_pass: 3, check_pass: 2]
    end
  end

  import Plug.Conn
  alias Phauxth.{Config, Log}

  @doc """
  Prints out a log message and adds a `phauxth_user` or `phauxth_error`
  message to the conn.

  The first argument to the function should be `{:ok, user}`,
  `{:error, error_log}` or `{:error, error_log, error_msg}`.
  error_log refers to what will be reported in the logs,
  and error_msg will be what the end user sees. If you call this
  function without a custom error_msg, the default value of
  `Invalid credentials` will be used.
  """
  def report({:ok, user}, conn, user_id, ok_log) do
    Log.info(conn, %Log{user: user_id, message: ok_log})
    put_private(conn, :phauxth_user, Map.drop(user, Config.drop_user_keys))
  end
  def report({:error, error_log}, conn, user_id, _) do
    Log.warn(conn, %Log{user: user_id, message: error_log})
    put_private(conn, :phauxth_error, "Invalid credentials")
  end
  def report({:error, error_log, error_msg}, conn, user_id, _) do
    Log.warn(conn, %Log{user: user_id, message: error_log})
    put_private(conn, :phauxth_error, error_msg)
  end
end
