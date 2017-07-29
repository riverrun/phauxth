defmodule Phauxth.Confirm do
  @moduledoc """
  Module to provide user confirmation.

  This Plug can be used to provide user confirmation by email, phone,
  or any other method.

  ## Options

  There is one option:

    * max_age - the length, in minutes, that the token is valid for
      * the default is 20 minutes

  ## Examples

  Add the following line to the `web/router.ex` file:

      get "/new", ConfirmController, :new

  Then add the following to the `confirm_controller.ex` new function:

      def new(conn, params) do
        case Phauxth.Confirm.verify(conn, params) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            message = "Your account has been confirmed"
            Message.confirm_success(user.email)
            handle_success(conn, message, session_path(conn, :new))
          {:error, message} ->
            handle_error(conn, message, session_path(conn, :new))
        end
      end

  In this example, the `Accounts.confirm_user` function updates the
  database, setting the `confirmed_at` value to the current time.
  """

  use Phauxth.Confirm.Base
  alias Phauxth.Token

  @doc """
  Generate a confirmation token.
  """
  def gen_token(conn, opts \\ []) do
    Token.sign(conn, opts)
  end
end
