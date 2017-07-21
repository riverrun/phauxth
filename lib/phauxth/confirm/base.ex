defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by both the Phauxth.Confirm and Phauxth.Confirm.PassReset
  modules.
  """

  @doc false
  defmacro __using__(options) do
    quote do
      import unquote(__MODULE__)
      import Plug.Crypto
      alias Phauxth.{Config, Log}

      @ok_log unquote(options)[:ok_log] || "account confirmed"

      @doc """
      Verify the confirmation key.
      """
      def verify(params, user_context, opts \\ [])
      def verify(%{"key" => key} = params, user_context, opts)
          when byte_size(key) == 32 do
        key_validity = Keyword.get(opts, :key_validity, 60)
        user_context.get_by(params)
        |> check_key(key, key_validity * 60)
        |> log(@ok_log)
      end
      def verify(_, _, _) do
        Log.warn(%Log{message: "invalid query string"})
        {:error, "Invalid credentials"}
      end

      @doc """
      Check the confirmation key.
      """
      def check_key(%{confirmed_at: nil, confirmation_sent_at: sent_time,
          confirmation_token: token} = user, key, valid_secs) do
        check_time(sent_time, valid_secs) and secure_compare(token, key) and {:ok, user}
      end
      def check_key(nil, _, _), do: {:error, "invalid credentials"}
      def check_key(_, _, _), do: {:error, "user account already confirmed"}

      @doc """
      Print out the log message and return {:ok, user} or {:error, message}.
      """
      def log({:ok, user}, ok_log) do
        Log.info(%Log{user: user.id, message: ok_log})
        {:ok, Map.drop(user, Config.drop_user_keys)}
      end
      def log(false, _) do
        log({:error, "invalid token"}, nil)
        {:error, "Invalid credentials"}
      end
      def log({:error, message}, _) do
        Log.warn(%Log{message: message})
        {:error, "Invalid credentials"}
      end

      defoverridable [verify: 3, check_key: 3, log: 2]
    end
  end

  @doc """
  Check that the key is still valid.
  """
  def check_time(nil, _), do: false
  def check_time(sent_at, valid_secs) do
    DateTime.to_unix(sent_at, :second) + valid_secs > System.system_time(:second)
  end
end
