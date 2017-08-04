defmodule Phauxth.Confirm do
  @moduledoc """
  Module to provide user confirmation.

  This Plug can be used to provide user confirmation by email, phone,
  or any other method.

  ## Examples

  Add the following line to the `web/router.ex` file:

      get "/new", ConfirmController, :new

  Then add the following to the `confirm_controller.ex` new function
  (this example is for a html app):

      def new(conn, params) do
        case Phauxth.Confirm.verify(params, Accounts, {conn, 20}) do
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

  use Phauxth.Confirm.Base

end
