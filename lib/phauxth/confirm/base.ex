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
      alias Phauxth.{Log, Report, Token}

      @doc """
      Verify the confirmation key and get the user data from the database.
      """
      def verify(conn, params, user_context, opts \\ [])
      def verify(conn, %{"key" => key}, user_context, opts) do
        max_age = Keyword.get(opts, :max_age, 20) * 60
        get_user(conn, {key, max_age, user_context}) |> log
      end
      def verify(_, _, _, _), do: log({:error, "no key found"})

      def get_user(conn, {key, max_age, user_context}) do
        with {:ok, params} <- Token.verify(conn, key, max_age: max_age),
          do: user_context.get_by(params)
      end

      @doc """
      Print out the log message and return {:ok, user} or {:error, message}.
      """
      def log(%{confirmed_at: nil} = user), do: Report.verify_ok(user, "user confirmed")
      def log(%{} = user), do: Report.verify_error(user, "user already confirmed")
      def log({:error, message}), do: Report.verify_error(message)
      def log(nil), do: Report.verify_error(nil)

      defoverridable [verify: 4, get_user: 2, log: 1]
    end
  end
end
