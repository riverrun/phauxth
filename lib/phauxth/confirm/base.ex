defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user / contact confirmation.

  This is used by both the Phauxth.Confirm and Phauxth.Confirm.PassReset
  modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Phauxth.Report
      alias Phauxth.Token

      @doc """
      Verify the confirmation key and get the user data from the database.

      The first argument is the parameters, which need to contain the confirmation
      key. The second argument is the user context module, and the third argument
      is a tuple containing the key source (conn or the name of the endpoint module)
      and the max age, in minutes.
      """
      def verify(%{"key" => key}, user_context, {key_source, max_age}) do
        get_user(key_source, {key, max_age * 60, user_context}) |> report
      end
      def verify(_, _, _), do: report({:error, "no key found"})

      def get_user(key_source, {key, max_age, user_context}) do
        with {:ok, params} <- Token.verify(key_source, key, max_age: max_age),
          do: user_context.get_by(params)
      end

      @doc """
      Print out the log message and return {:ok, user} or {:error, message}.
      """
      def report(%{confirmed_at: nil} = user), do: verify_ok(user, "user confirmed")
      def report(%{} = user), do: verify_error(user, "user already confirmed")
      def report({:error, message}), do: verify_error(message)
      def report(nil), do: verify_error(nil)

      defoverridable [verify: 3, get_user: 2, report: 1]
    end
  end
end
