defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      alias Comeonin.Bcrypt
      alias Phauxth.Config

      @behaviour Phauxth

      @doc false
      def verify(params, opts \\ []) do
        identifier = Keyword.get(opts, :identifier, :email)
        user_params = to_string(identifier)
        %{^user_params => user_id, "password" => password} = params
        Config.repo.get_by(Config.user_mod, [{identifier, user_id}])
        |> check_pass(password)
        |> log(user_id, "successful login")
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

      defoverridable [verify: 2, check_pass: 2]
    end
  end

  alias Phauxth.{Config, Log}

  @doc """
  Prints out a log message.
  """
  def log({:ok, user}, user_id, ok_log) do
    Log.info(%Log{user: user_id, message: ok_log})
    {:ok, Map.drop(user, Config.drop_user_keys)}
  end
  def log({:error, error_log}, user_id, _) do
    Log.warn(%Log{user: user_id, message: error_log})
    {:error, "Invalid credentials"}
  end
end
