defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by Phauxth.Confirm and can also be used to create
  custom user confirmation modules.
  """

  @doc """
  Verify the confirmation key and get the user data from the database.

  `Phauxth.Confirm.verify` is used to confirm an email for new users
  and `Phauxth.Confirm.PassReset.verify` is used for password resetting.

  ## Options

  There are three options for the verify function:

    * `:endpoint` - the name of the endpoint of your app
      * this can also be set in the config
    * `:max_age` - the maximum age of the token, in seconds
      * the default is 1200 seconds (20 minutes)
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  In addition, there are also options for verifying the token.
  See the documentation for the Phauxth.Token module for details.

  ## Examples

  The following function is an example of using `Phauxth.Confirm.verify`
  in a Phoenix controller.

      def index(conn, params) do
        case Phauxth.Confirm.verify(params, Accounts) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            message = "Your account has been confirmed"
            Accounts.Message.confirm_success(user.email)
            handle_success() # redirect or send json
          {:error, message} ->
            handle_error()
        end
      end

  In this example, the `Accounts.confirm_user` function updates the
  database, setting the `confirmed_at` value to the current time.

  ### Password resetting

  For password resetting, use `Phauxth.Confirm.PassReset.verify`, as
  in the following example:

      def update(conn, %{"password_reset" => params}) do
        case Phauxth.Confirm.PassReset.verify(params, Accounts) do
          {:ok, user} ->
            Accounts.update_password(user, params)
            |> handle_password_reset(conn, params)
          {:error, message} ->
            handle_error()
        end
      end

  The `Accounts.update_password` function tries to add the new password
  to the database. If the password reset is successful, the `handle_password_reset`
  function sends a message (email or phone) to the user and redirects the
  user to the next page or sends a json response. If unsuccessful, the
  `handle_password_reset` function handles the error.
  """
  @callback verify(params :: map, user_context :: module, opts :: keyword) ::
              {:ok, map} | {:error, String.t()}

  @doc """
  Get the user struct based on the supplied key.
  """
  @callback get_user(key_source :: term, opts :: tuple) :: map | nil

  @doc """
  Print out a log message and then return {:ok, user} or
  {:error, message} to the calling function.
  """
  @callback report(result :: map, meta :: keyword) :: {:ok, map} | {:error, String.t()}

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Confirm.Base

      import Phauxth.Confirm.Base
      alias Phauxth.{Config, Log, Token}

      @impl true
      def verify(params, user_context, opts \\ [])

      def verify(%{"key" => key}, user_context, opts) do
        endpoint = Keyword.get(opts, :endpoint, Config.endpoint())
        max_age = Keyword.get(opts, :max_age, 1200)
        log_meta = Keyword.get(opts, :log_meta, [])

        get_user(endpoint, {key, max_age, user_context, opts})
        |> report(log_meta)
      end

      def verify(_, _, _), do: raise(ArgumentError, "No key found in the params")

      @impl true
      def get_user(key_source, {key, max_age, user_context, opts}) do
        with {:ok, params} <- Token.verify(key_source, key, max_age, opts),
             do: user_context.get_by(params)
      end

      @impl true
      def report({:error, message}, meta) do
        Log.warn(%Log{message: message, meta: meta})
        {:error, Config.user_messages().default_error()}
      end

      def report(nil, meta), do: report({:error, "no user found"}, meta)

      defoverridable Phauxth.Confirm.Base
    end
  end

  alias Phauxth.{Config, Log}

  @doc """
  Check if the user has been confirmed.
  """
  @spec check_user_confirmed(map, list) :: {:ok, map} | {:error, String.t()}
  def check_user_confirmed(%{confirmed_at: nil} = user, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end

  def check_user_confirmed(%{} = user, meta) do
    Log.warn(%Log{user: user.id, message: "user already confirmed", meta: meta})
    {:error, Config.user_messages().already_confirmed()}
  end

  @doc """
  Check if a reset token has been sent to the user.
  """
  @spec check_reset_sent_at(map, list) :: {:ok, map} | {:error, String.t()}
  def check_reset_sent_at(%{reset_sent_at: nil}, meta) do
    Log.warn(%Log{message: "no reset token found", meta: meta})
    {:error, Config.user_messages().default_error()}
  end

  def check_reset_sent_at(%{reset_sent_at: _time} = user, meta) do
    Log.info(%Log{user: user.id, message: "user confirmed for password reset", meta: meta})
    {:ok, Map.drop(user, Config.drop_user_keys())}
  end
end
