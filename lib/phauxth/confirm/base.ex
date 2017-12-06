defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by Phauxth.Confirm and can also be used to create
  custom user confirmation modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Phauxth.Confirm.Report
      alias Phauxth.{Config, Token}

      @behaviour Phauxth

      @doc """
      Verify the confirmation key and get the user data from the database.

      This can be used to confirm an email for new users and also for
      password resetting.

      ## Options

      There are four options for the verify function:

        * `:endpoint` - the name of the endpoint of your app
          * this can also be set in the config
        * `:max_age` - the maximum age of the token, in seconds
          * the default is 1200 seconds (20 minutes)
        * `:mode` - the mode - email confirmation or password resetting
          * set this to :pass_reset to use this function for password resetting
        * `:log_meta` - additional custom metadata for Phauxth.Log
          * this should be a keyword list

      In addition, there are also options for generating the token.
      See the documentation for the Phauxth.Token module for details.

      ## Examples

      The following function is an example of using verify in a Phoenix
      controller.

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

      For password resetting, use the `mode: :pass_reset` option, as in the
      following example:

          def update(conn, %{"password_reset" => params}) do
            case Phauxth.Confirm.verify(params, Accounts, mode: :pass_reset) do
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
      def verify(params, user_context, opts \\ [])
      def verify(%{"key" => key}, user_context, opts) do
        endpoint = Keyword.get(opts, :endpoint, Config.endpoint)
        max_age = Keyword.get(opts, :max_age, 1200)
        log_meta = Keyword.get(opts, :log_meta, [])

        get_user(endpoint, {key, max_age, user_context, opts})
        |> report(opts[:mode], log_meta)
      end
      def verify(_, _, _), do: raise ArgumentError, "No key found in the params"

      def get_user(key_source, {key, max_age, user_context, opts}) do
        with {:ok, params} <- Token.verify(key_source, key, max_age, opts),
          do: user_context.get_by(params)
      end

      defoverridable [verify: 2, verify: 3, get_user: 2]
    end
  end
end
