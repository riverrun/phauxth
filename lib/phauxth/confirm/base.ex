defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by both the Phauxth.Confirm and Phauxth.Confirm.PassReset
  modules.

  ## Custom confirmation modules

  One example of a custom confirmation module is provided by the
  Phauxth.Confirm.PassReset module, which extends this base module to add
  the password reset functionality.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        identifier = Keyword.get(opts, :identifier, :email)
        {identifier, to_string(identifier), Keyword.get(opts, :key_validity, 60)}
      end

      @doc false
      def call(conn, {identifier, user_params, key_expiry}) do
        with %{^user_params => user_id, "key" => key} = params <- conn.query_params do
          check_confirm conn, {identifier, user_id, key, key_expiry, :nopass}
        else
          _ -> check_confirm conn, nil
        end
      end

      defoverridable [init: 1, call: 2]
    end
  end

  import Plug.{Conn, Crypto}
  alias Phauxth.Confirm.DB_Utils
  alias Phauxth.{Config, Log}

  @doc """
  Function to confirm the user by checking the token.
  """
  def check_confirm(conn, {identifier, user_id, key, key_expiry, password})
      when byte_size(key) == 32 do
    Config.repo.get_by(Config.user_mod, [{identifier, user_id}])
    |> check_key(key, key_expiry * 60, password)
    |> finalize(conn, user_id, password)
  end
  def check_confirm(conn, _) do
    Log.log(:warn, Config.log_level, conn.request_path,
            %Log{message: "invalid query string",
              meta: [{"query", conn.query_string}]})
    put_private(conn, :phauxth_error, "Invalid credentials")
  end

  defp check_key(nil, _, _, _), do: {:error, "invalid credentials"}
  defp check_key(%{confirmed_at: nil} = user, key, valid_secs, :nopass) do
    DB_Utils.check_time(user.confirmation_sent_at, valid_secs) and
    secure_compare(user.confirmation_token, key) and
    DB_Utils.user_confirmed(user) || {:error, "invalid token"}
  end
  defp check_key(_, _, _, :nopass), do: {:error, "user account already confirmed"}
  defp check_key(user, key, valid_secs, password) do
    DB_Utils.check_time(user.reset_sent_at, valid_secs) and
    secure_compare(user.reset_token, key) and
    DB_Utils.password_reset(user, password) || {:error, "invalid token"}
  end

  defp finalize({:ok, user}, conn, user_id, password) do
    message = if password == :nopass, do: "account confirmed", else: "password reset"
    Log.log(:info, Config.log_level, conn.request_path, %Log{user: user_id, message: message})
    put_private(conn, :phauxth_user, Map.drop(user, Config.drop_user_keys))
  end
  defp finalize({:error, message}, conn, user_id, _) do
    Log.log(:warn, Config.log_level, conn.request_path,
            %Log{user: user_id,
              message: message,
              meta: [{"current_user_id", Log.current_user_id(conn.assigns)}]})
    put_private(conn, :phauxth_error, "Invalid credentials")
  end
end
