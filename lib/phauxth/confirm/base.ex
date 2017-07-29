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
      alias Phauxth.Token

      @doc """
      Verify the confirmation key.
      """
      def verify(conn, %{"key" => key}, user_context, opts \\ []) do
        max_age = Keyword.get(opts, :max_age, 20)
        get_user(conn, {key, max_age * 60, user_context}) |> log("user confirmed")
      end

      def get_user(conn, {token, max_age, user_context}) do
        with {:ok, params} <- Token.verify(conn, token, max_age: max_age),
             %{confirmed_at: time} = user <- user_context.get_by(params),
          do: time && {:error, user.id, "user already confirmed"} || user
      end

      defoverridable [verify: 4, get_user: 2]
    end
  end

  alias Phauxth.{Config, Log}

  @doc """
  Print out the log message and return {:ok, user} or {:error, message}.
  """
  def log({:error, msg}, _) do
    Log.warn(%Log{message: "#{msg} token"})
    {:error, "Invalid credentials"}
  end
  def log({:error, id, msg}, _) do
    Log.warn(%Log{user: id, message: msg})
    {:error, "The user has already been confirmed"}
  end
  def log(user, ok_log) do
    Log.info(%Log{user: user.id, message: ok_log})
    {:ok, Map.drop(user, Config.drop_user_keys)}
  end
end
