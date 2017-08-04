defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.

  ## Custom login modules

  One example of a custom login module is provided by the Phauxth.Confirm.Login
  module, which is shown below:

      defmodule Phauxth.Confirm.Login do
        use Phauxth.Login.Base

        def check_pass(%{confirmed_at: nil}, _, _, _), do: {:error, "account unconfirmed"}
        def check_pass(user, password, crypto, crypto_opts) do
          super(user, password, crypto, crypto_opts)
        end
      end

  In the Phauxth.Confirm.Login module, the user struct is checked to see
  if the user is confirmed. If the user has not been confirmed, an error
  is returned. Otherwise, the default check_pass function is run.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Phauxth.Report

      @doc """
      Verify a user's password.
      """
      def verify(params, user_context, opts \\ [])
      def verify(%{"password" => password} = params, user_context, opts) do
        {crypto, crypto_opts} = Keyword.pop(opts, :crypto, Comeonin.Bcrypt)
        user_context.get_by(params)
        |> check_pass(password, crypto, crypto_opts)
        |> report
      end
      def verify(_, _, _), do: report({:error, "no password found"})

      @doc """
      Check the password by comparing it with a stored hash.

      The stored hash, in the user struct, should have `password_hash`
      or `encrypted_password` as a key.
      """
      def check_pass(user, password, crypto, crypto_opts) do
        crypto.check_pass(user, password, crypto_opts)
      end

      @doc """
      Prints out a log message and returns {:ok, user} or {:error, message}.
      """
      def report({:ok, user}), do: verify_ok(user, "successful login")
      def report({:error, message}), do: verify_error(message)

      defoverridable [verify: 3, check_pass: 4, report: 1]
    end
  end
end
