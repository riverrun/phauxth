defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Phauxth.Utils
      import unquote(__MODULE__)
      alias Comeonin.Bcrypt

      @behaviour Phauxth

      def init(opts) do
        {Keyword.get(opts, :identifier, :email),
        {Keyword.get(opts, :repo, default_repo()),
        Keyword.get(opts, :user_schema, default_user_schema())}}
      end

      @doc false
      def verify(params, opts \\ []) do
        {identifier, {repo, user_schema}} = init(opts)
        user_params = to_string(identifier)
        %{^user_params => user_id, "password" => password} = params
        repo.get_by(user_schema, [{identifier, user_id}])
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

      defoverridable [init: 1, verify: 2, check_pass: 2]
    end
  end

  alias Phauxth.{Config, Log}

  @doc """
  Prints out a log message and returns {:ok, user} or {:error, message}.
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
