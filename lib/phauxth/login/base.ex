defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.

  ## Custom login modules

  One example of a custom login module is provided by the Phauxth.Confirm.Login
  module, which is shown below:

      defmodule Phauxth.Confirm.Login do
        use Phauxth.Login.Base

        def check_pass(%{confirmed_at: nil}, _, _, _), do: {:error, "account unconfirmed"}
        def check_pass(user, password, crypto, opts), do: super(user, password, crypto, opts)
      end

  In the Phauxth.Confirm.Login module, the user struct is checked to see
  if the user is confirmed. If the user has not been confirmed, an error
  is returned. Otherwise, the default check_pass function is run.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @doc """
      Verify a user's password.
      """
      def verify(%{"password" => password} = params, user_context, opts \\ []) do
        crypto = Keyword.get(opts, :crypto, Comeonin.Bcrypt)
        user_context.get_by(params)
        |> check_pass(password, crypto, opts)
        |> log("successful login")
      end

      @doc """
      Check the password by comparing it with a stored hash.

      The stored hash, in the user struct, should have `password_hash`
      or `encrypted_password` as a key.
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
  def log({:ok, user}, ok_log) do
    Log.info(%Log{user: user.id, message: ok_log})
    {:ok, Map.drop(user, Config.drop_user_keys)}
  end
  def log({:error, error_log}, _) do
    Log.warn(%Log{message: error_log})
    {:error, "Invalid credentials"}
  end
end
