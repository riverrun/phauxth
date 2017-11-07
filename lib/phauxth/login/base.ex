defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.

  This is used by Phauxth.Login and can also be used to create
  custom login modules.

  ## Custom login modules

  One example of a custom login module is provided by the Phauxth.Confirm.Login
  module, which is shown below:

      defmodule Phauxth.Confirm.Login do
        use Phauxth.Login.Base

        def check_pass(%{confirmed_at: nil}, _, _, _), do: {:error, "account unconfirmed"}
        def check_pass(user, password, crypto, opts) do
          super(user, password, crypto, opts)
        end
      end

  In this example, the check_pass function is overridden to check
  the user struct to see if the user is confirmed. If the user has not
  been confirmed, an error is returned. Otherwise, the default check_pass
  function is run.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Plug.Conn

      @behaviour Phauxth

      @doc """
      Verify a user's password.

      Check the user's password, and return {:ok, user} if login is
      successful or {:error, message} if there is an error.

      If login is successful, you need to either add the user to the
      session, by running `put_session(conn, :user_id, id)`, or send
      an api token to the user.

      ## Options

      There are two options for the verify function:

        * crypto - the password hashing module to use
          * the default is Comeonin.Bcrypt
        * log_meta - additional custom metadata for Phauxth.Log
          * this should be a keyword list

      The check_pass function also has options. See the documentation for
      the password hashing module you are using for details.

      ## Examples

      The following function is an example of using verify in a Phoenix
      controller.

          def create(conn, %{"session" => params}) do
            case Phauxth.Login.verify(params, MyApp.Accounts) do
              {:ok, user} ->
                put_session(conn, :user_id, user.id)
                |> configure_session(renew: true)
                |> success("You have been logged in", user_path(conn, :index))
              {:error, message} ->
                error(conn, message, session_path(conn, :new))
            end
          end

      In this example, if the login is successful, the user is added to
      the session, which is then renewed, and then is redirected
      to the /users page.
      """
      def verify(params, user_context, opts \\ [])
      def verify(%{"password" => password} = params, user_context, opts) do
        crypto = Keyword.get(opts, :crypto, Comeonin.Bcrypt)
        log_meta = Keyword.get(opts, :log_meta, [])

        user_context.get_by(params)
        |> check_pass(password, crypto, opts)
        |> report("successful login", log_meta)
      end
      def verify(_, _, _), do: raise ArgumentError, "No password found in the params"

      @doc """
      Check the password by comparing it with a stored hash.

      The stored hash, in the user struct, should have `password_hash`
      or `encrypted_password` as a key.
      """
      def check_pass(user, password, crypto, opts) do
        crypto.check_pass(user, password, opts)
      end

      @doc """
      Add the phauxth_session_id to the conn.
      """
      def add_session(conn, session_id, user_id) do
        put_session(conn, :phauxth_session_id, session_id <> to_string(user_id))
        |> configure_session(renew: true)
      end

      @doc """
      Generate a session id.
      """
      def gen_session_id(fresh) do
        "#{fresh}#{:crypto.strong_rand_bytes(12) |> Base.encode64}"
      end

      defoverridable [verify: 2, verify: 3, check_pass: 4]
    end
  end

  alias Phauxth.{Config, Log}

  @doc """
  Prints out a log message and returns {:ok, user} or {:error, message}.
  """
  def report({:ok, user}, ok_message, meta) do
    Log.info(%Log{user: user.id, message: ok_message, meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys)}
  end
  def report({:error, "account unconfirmed"}, _, meta) do
    Log.warn(%Log{message: "account unconfirmed", meta: meta})
    {:error, Config.user_messages.need_confirm()}
  end
  def report({:error, message}, _, meta) do
    Log.warn(%Log{message: message, meta: meta})
    {:error, Config.user_messages.invalid()}
  end
end
