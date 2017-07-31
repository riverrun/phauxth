defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Confirm a user in order to reset the password.

  ## Options

  There is one option:

    * max_age - the length, in minutes, that the token is valid for
      * the default is 20 minutes

  ## Examples

  Add the following lines to the `web/router.ex` file (for a html app):

      resources "/password_resets", PasswordResetController, only: [:new, :create]
      get "/password_resets/edit", PasswordResetController, :edit
      put "/password_resets/update", PasswordResetController, :update

  and for an api, add:

      post "/password_resets/create", PasswordResetController, :create
      put "/password_resets/update", PasswordResetController, :update

  Then add the following to the `password_reset_controller.ex` update function
  (this example is for a html app):

      def update(conn, %{"password_reset" => params}) do
        case Phauxth.Confirm.PassReset.verify(conn, params, max_age: 15) do
          {:ok, user} ->
            Accounts.update_user(user, params)
            Message.reset_success(user.email)
            message = "Your password has been reset"
            configure_session(conn, drop: true)
            |> handle_success(message, session_path(conn, :new))
          {:error, message} ->
            conn
            |> put_flash(:error, message)
            |> render("edit.html", email: params["email"], key: params["key"])
        end
      end

  In this example, the `Accounts.update_user` function updates the
  database, setting the `password_hash` value to the hash for the
  new password and the `reset_token` and `reset_sent_at` values to nil.
  """

  use Phauxth.Confirm.Base

  @doc """
  Print out the log message and return {:ok, user} or {:error, message}.
  """
  def log(%{} = user), do: Report.verify_ok(user, "user confirmed")
  def log(%{reset_sent_at: nil} = user) do
    Report.verify_error(user, "no reset token found")
  end
  def log({:error, message}), do: Report.verify_error(message)
  def log(nil), do: Report.verify_error(nil)
end
