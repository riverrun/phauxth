defmodule Phauxth.Login do
  @moduledoc """
  Module to handle login.

  ## Custom login modules

  One example of a custom login module is provided by the Phauxth.Confirm.Login
  module, which is shown below:

      defmodule Phauxth.Confirm.Login do
        use Phauxth.Login

        def check_pass(%{confirmed_at: nil}, _, _, _), do: {:error, "account unconfirmed"}
        def check_pass(user, password, crypto, opts) do
          super(user, password, crypto, opts)
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

      In the example below, verify is called within the create
      function in the session controller.

          use Phauxth.Login

          def create(conn, %{"session" => params}) do
            case verify(params, MyApp.Accounts) do
              {:ok, user} -> handle_successful_login
              {:error, message} -> handle_error
            end
          end

      """
      def verify(params, user_context, opts \\ [])
      def verify(%{"password" => password} = params, user_context, opts) do
        crypto = Keyword.get(opts, :crypto, Comeonin.Bcrypt)
        log_meta = Keyword.get(opts, :log_meta, [])

        user_context.get_by(params)
        |> check_pass(password, crypto, opts)
        |> report(log_meta)
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

      defoverridable [verify: 3, check_pass: 4]
    end
  end

  alias Phauxth.{Config, Log}

  @messages %{
    "account unconfirmed" => "The account needs to be confirmed"
  }

  @doc """
  Prints out a log message and returns {:ok, user} or {:error, message}.
  """
  def report({:ok, user}, meta) do
    Log.info(%Log{user: user.id, message: "successful login", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys)}
  end
  def report({:error, message}, meta) do
    Log.warn(%Log{message: message, meta: meta})
    {:error, @messages[message] || "Invalid credentials"}
  end
end
