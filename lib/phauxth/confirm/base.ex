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

      import Plug.{Conn, Crypto}
      import unquote(__MODULE__)
      alias Phauxth.{Config, Log}

      @doc false
      def init(opts) do
        identifier = Keyword.get(opts, :identifier, :email)
        {identifier, to_string(identifier), Keyword.get(opts, :key_validity, 60)}
      end

      @doc false
      def call(conn, {identifier, user_params, key_expiry}) do
        with %{^user_params => user_id, "key" => key} = params <- conn.query_params do
          check_confirm conn, {identifier, user_id, key, key_expiry, "account confirmed"}
        else
          _ -> check_confirm conn, nil
        end
      end

      @doc """
      Function to confirm the user by checking the token.
      """
      def check_confirm(conn, {identifier, user_id, key, key_expiry, ok_msg})
          when byte_size(key) == 32 do
        Config.repo.get_by(Config.user_mod, [{identifier, user_id}])
        |> check_key(key, key_expiry * 60)
        |> finalize(conn, user_id, ok_msg)
      end
      def check_confirm(conn, _) do
        Log.log(:warn, Config.log_level, conn.request_path,
                %Log{message: "invalid query string",
                  meta: [{"query", conn.query_string}]})
        put_private(conn, :phauxth_error, "Invalid credentials")
      end

      @doc """
      """
      def check_key(%{confirmed_at: nil, confirmation_sent_at: sent_time,
          confirmation_token: token} = user, key, valid_secs) do
        check_time(sent_time, valid_secs) and secure_compare(token, key) and user
      end
      def check_key(nil, _, _), do: {:error, "invalid credentials"}

      defoverridable [init: 1, call: 2, check_confirm: 2, check_key: 3]
    end
  end

  import Plug.Conn
  alias Phauxth.{Config, Log}

  def check_time(nil, _), do: false
  def check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  def finalize(false, conn, user_id, _) do
    finalize({:error, "invalid token"}, conn, user_id, nil)
  end
  def finalize({:error, message}, conn, user_id, _) do
    Log.log(:warn, Config.log_level, conn.request_path,
            %Log{user: user_id,
              message: message,
              meta: [{"current_user_id", Log.current_user_id(conn.assigns)}]})
    put_private(conn, :phauxth_error, "Invalid credentials")
  end
  def finalize(user, conn, user_id, ok_msg) do
    Log.log(:info, Config.log_level, conn.request_path,
            %Log{user: user_id, message: ok_msg})
    put_private(conn, :phauxth_user, user)
  end
end
