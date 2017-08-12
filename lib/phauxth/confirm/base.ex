defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Module to provide user confirmation for new users and when resetting
  passwords.

  ## Examples

  Add the following line to the `web/router.ex` file:

      get "/new", ConfirmController, :new

  Then add the following to the `confirm_controller.ex` new function
  (this example is for a html app):

      def new(conn, params) do
        case verify(params, Accounts) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            Message.confirm_success(user.email)
            conn
            |> put_flash(:info, "Your account has been confirmed")
            |> redirect(to: session_path(conn, :new))
          {:error, message} ->
            conn
            |> put_flash(:error, message)
            |> redirect(to: session_path(conn, :new))
            |> halt
        end
      end

  In this example, the `Accounts.confirm_user` function updates the
  database, setting the `confirmed_at` value to the current time.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Phauxth.Confirm.Report
      alias Phauxth.Token

      @doc """
      Verify the confirmation key and get the user data from the database.

      This can be used to confirm an email for new users and also for
      password resetting.

      ## Options

      There are three options for the verify function:

        * key_source - conn or the name of the endpoint module
          * the default is MyAppWeb.Endpoint
        * max_age - the maximum age of the token, in seconds
          * the default is 1200 seconds (20 minutes)
        * mode - if the function is for email confirmation or password resetting
          * set this to :pass_reset to use this function for password resetting
        * log_meta - additional custom metadata for Phauxth.Log
          * this should be a keyword list

      """
      def verify(params, user_context, opts \\ [])
      def verify(%{"key" => key}, user_context, opts) do
        key_source = Keyword.get(opts, :key_source, Phauxth.Utils.default_endpoint())
        max_age = Keyword.get(opts, :max_age, 1200)
        log_meta = Keyword.get(opts, :log_meta, [])

        get_user(key_source, {key, max_age, user_context})
        |> report(opts[:mode], log_meta)
      end
      def verify(_, _, _), do: raise ArgumentError, "No key found in the params"

      def get_user(key_source, {key, max_age, user_context}) do
        with {:ok, params} <- Token.verify(key_source, key, max_age),
          do: user_context.get_by(params)
      end

      defoverridable [verify: 3, get_user: 2]
    end
  end
end
