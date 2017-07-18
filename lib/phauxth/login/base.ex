defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @doc """
      Verify a user's password.

      ## Examples

      The example below shows how you can use this function in the
      create function of a Phoenix session controller:

          def create(conn, %{"session" => params}) do
            case Phauxth.Login.verify(params, MyApp.Accounts) do
              {:ok, user} -> handle_successful_login
              {:error, message} -> handle_error
            end
          end

      """
      def verify(params, user_data, opts \\ []) do
        {identifier, crypto} = {Keyword.get(opts, :identifier, :email),
          Keyword.get(opts, :crypto, Comeonin.Bcrypt)}
        user_params = to_string(identifier)
        %{^user_params => user_id, "password" => password} = params
        user_data.get_by([{identifier, user_id}])
        |> check_pass(password, crypto, opts)
        |> log(user_id, "successful login")
      end

      @doc """
      Check the password by comparing it with a stored hash.
      """
      def check_pass(user, password, crypto, opts) do
        crypto.check_pass(user, password, opts)
      end

      defoverridable [verify: 3, check_pass: 4]
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
