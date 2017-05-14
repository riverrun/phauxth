defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by both the Phauxth.Confirm and Phauxth.Confirm.PassReset
  modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      alias Phauxth.{Config, Log}

      @doc false
      def verify(conn, params, opts \\ [identifier: :email, key_validity: 60]) do
        user_params = to_string(opts[:identifier])
        with %{^user_params => user_id, "key" => key} <- conn.query_params do
          check_confirm(conn, {opts[:identifier], user_id,
            key, opts[:key_validity], "account confirmed"})
        else
          _ -> check_confirm(conn, nil)
        end
      end

      @doc """
      Function to confirm the user by checking the token.
      """
      def check_confirm(conn, {identifier, user_id, key, key_expiry, ok_log})
          when byte_size(key) == 32 do
        Config.repo.get_by(Config.user_mod, [{identifier, user_id}])
        |> check_key(key, key_expiry * 60)
        |> log(conn, user_id, ok_log)
      end
      def check_confirm(conn, _) do
        Log.warn(conn, %Log{message: "invalid query string",
          meta: [{"query", conn.query_string}]})
        {:error, "Invalid credentials"}
      end

      @doc """
      """
      def log({:ok, user}, conn, user_id, ok_log) do
        Log.info(conn, %Log{user: user_id, message: ok_log})
        {:ok, Map.drop(user, Config.drop_user_keys)}
      end
      def log(false, conn, user_id, _) do
        log({:error, "invalid token"}, conn, user_id, nil)
        {:error, "Invalid credentials"}
      end
      def log({:error, message}, conn, user_id, _) do
        Log.warn(conn, %Log{user: user_id, message: message,
          meta: [{"current_user_id", Log.current_user_id(conn.assigns)}]})
        {:error, "Invalid credentials"}
      end

      defoverridable [verify: 4, check_confirm: 2, log: 4]
    end
  end

  import Plug.Crypto

  @doc """
  """
  def check_key(%{confirmed_at: nil, confirmation_sent_at: sent_time,
      confirmation_token: token} = user, key, valid_secs) do
    check_time(sent_time, valid_secs) and secure_compare(token, key) and {:ok, user}
  end
  def check_key(nil, _, _), do: {:error, "invalid credentials"}
  def check_key(_, _, _), do: {:error, "user account already confirmed"}

  @doc """
  """
  def check_time(nil, _), do: false
  def check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end
end
