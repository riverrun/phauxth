defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by Phauxth.Confirm and Phauxth.Confirm.PassReset,
  and it can also be used to create custom user confirmation modules.
  """

  @type error_message :: {:error, String.t()}

  @doc """
  Verifies the confirmation key and gets the user data from the database.

  `Phauxth.Confirm.verify` is used to confirm an email for new users
  and `Phauxth.Confirm.PassReset.verify` is used for password resetting.

  ## Options

  There are two options for the verify function:

    * `:user_context` - the users module to be used when querying the database
      * the default is Phauxth.Config.user_context()
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  In addition, there are also options for verifying the token, including
  a `max_age` option, which defaults to 1200 seconds (20 minutes).

  ## Examples

  The following function is an example of using `Phauxth.Confirm.verify`
  in a Phoenix controller.

      def index(conn, params) do
        case Phauxth.Confirm.verify(params) do
          {:ok, user} ->
            Users.confirm_user(user)
            message = "Your account has been confirmed"
            Users.Message.confirm_success(user.email)
            handle_success() # redirect or send json
          {:error, message} ->
            handle_error()
        end
      end

  In this example, the `Users.confirm_user` function updates the
  database, setting the `confirmed_at` value to the current time.

  ### Password resetting

  For password resetting, use `Phauxth.Confirm.PassReset.verify`, as
  in the following example:

      def update(conn, %{"password_reset" => params}) do
        case Phauxth.Confirm.PassReset.verify(params) do
          {:ok, user} ->
            Users.update_password(user, params)
            |> handle_password_reset(conn, params)
          {:error, message} ->
            handle_error()
        end
      end

  The `Users.update_password` function tries to add the new password
  to the database. If the password reset is successful, the `handle_password_reset`
  function sends a message by email to the user and redirects the
  user to the next page or sends a json response. If unsuccessful, the
  `handle_password_reset` function handles the error.
  """
  @callback verify(map, keyword) :: {:ok, map} | error_message

  @doc """
  Gets the user data using the key in the params.

  In the default implementation, this function retrieves user information
  using the `get_by` function defined in the `user_context` module.
  """
  @callback get_user(binary, map) :: map | nil

  @doc """
  Prints out a log message and then returns {:ok, user} or
  {:error, message} to the calling function.
  """
  @callback report(map, keyword) :: {:ok, map} | error_message

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Confirm.Base

      import Phauxth.Confirm.Base
      alias Phauxth.{Config, Log}

      @impl true
      def verify(params, opts \\ [])

      def verify(%{"key" => token}, opts) do
        {user_context, opts} = Keyword.pop(opts, :user_context, Config.user_context())
        {log_meta, opts} = Keyword.pop(opts, :log_meta, [])
        options = %{user_context: user_context, log_meta: log_meta, opts: opts}
        token |> get_user(options) |> report(log_meta)
      end

      def verify(_, _), do: raise(ArgumentError, "No key found in the params")

      @impl true
      def get_user(token, %{user_context: user_context, opts: opts}) do
        token_mod = Config.token_module()

        with {:ok, params} <- token_mod.verify(token, opts ++ [max_age: 1200]),
             do: user_context.get_by(params)
      end

      @impl true
      def report(%{} = user, meta) do
        Log.info(%Log{user: user.id, message: "user confirmed", meta: meta})
        {:ok, Map.drop(user, Config.drop_user_keys())}
      end

      def report({:error, message}, meta) do
        Log.warn(%Log{message: message, meta: meta})
        {:error, Config.user_messages().default_error()}
      end

      def report(nil, meta), do: report({:error, "no user found"}, meta)

      defoverridable Phauxth.Confirm.Base
    end
  end
end
