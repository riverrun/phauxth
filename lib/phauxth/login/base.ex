defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      alias Comeonin.Bcrypt
      alias Phauxth.{Config, Log}

      @doc false
      def verify(conn, params, opts \\ [identifier: :email]) do
        user_params = to_string(opts[:identifier])
        %{^user_params => user_id, "password" => password} = params
        Config.repo.get_by(Config.user_mod, [{opts[:identifier], user_id}])
        |> check_pass(password)
        |> log(conn, user_id, "successful login")
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

      @doc """
      Prints out a log message.
      """
      def log({:ok, user}, conn, user_id, ok_log) do
        Log.info(conn, %Log{user: user_id, message: ok_log})
        {:ok, Map.drop(user, Config.drop_user_keys)}
      end
      def log({:error, error_log}, conn, user_id, _) do
        Log.warn(conn, %Log{user: user_id, message: error_log})
        {:error, "Invalid credentials"}
      end

      defoverridable [verify: 3, check_pass: 2, log: 4]
    end
  end
end
