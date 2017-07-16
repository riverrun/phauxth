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
      def verify(params, user_data, opts \\ []) do
        {identifier, key_validity} = unpack(opts)
        user_params = to_string(identifier)
        with %{^user_params => user_id, "key" => key} <- params do
          check_confirm({identifier, user_id, key, key_validity, @ok_log}, user_data)
        else
          _ -> check_confirm(nil, user_data)
        end
      end

      @doc """
      Function to confirm the user by checking the token.
      """
      def check_confirm({identifier, user_id, key, key_expiry, ok_log}, user_data)
          when byte_size(key) == 32 do
        user_data.get_by([{identifier, user_id}])
        |> check_key(key, key_expiry * 60)
        |> log(user_id, ok_log)
      end
      def check_confirm(_, _) do
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
      def log({:ok, user}, user_id, ok_log) do
        Log.info(%Log{user: user_id, message: ok_log})
        {:ok, Map.drop(user, Config.drop_user_keys)}
      end
      def log(false, user_id, _) do
        log({:error, "invalid token"}, user_id, nil)
        {:error, "Invalid credentials"}
      end
      def log({:error, message}, user_id, _) do
        Log.warn(%Log{user: user_id, message: message})
        {:error, "Invalid credentials"}
      end

      defp unpack(opts) do
        {Keyword.get(opts, :identifier, :email),
        Keyword.get(opts, :key_validity, 60)}
      end

      defoverridable [verify: 3, check_confirm: 2, check_key: 3, log: 3]
    end
  end

  @doc """
  """
  def check_time(nil, _), do: false
  def check_time(sent_at, valid_secs) do
    (to_erl(sent_at) |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp to_erl(%{year: year, month: month, day: day, hour: hour, min: min, sec: sec}) do
    {{year, month, day}, {hour, min, sec}}
  end
  defp to_erl(%{year: year, month: month, day: day, hour: hour, minute: minute, second: second}) do
    {{year, month, day}, {hour, minute, second}}
  end
end
