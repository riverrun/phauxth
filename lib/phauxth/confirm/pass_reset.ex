defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Confirm a user and reset the password.

  ## Options

  There are two options:

    * identifier - how the user is identified in the confirmation request
      * this should be an atom, and the default is :email
    * key_validity - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)

  ## Examples

  Add the following lines to the `web/router.ex` file (for a html app):

      resources "/password_resets", PasswordResetController, only: [:new, :create]
      get "/password_resets/edit", PasswordResetController, :edit
      put "/password_resets/update", PasswordResetController, :update

  and for an api, add:

      post "/password_resets/create", PasswordResetController, :create
      put "/password_resets/update", PasswordResetController, :update

  Then add the following to the `password_reset_controller.ex` update function:

      def update(conn, %{"password_reset" => params}) do
        case Phauxth.Confirm.PassReset.verify(params) do
          {:ok, user} -> handle_successful_password_reset
          {:error, message} -> handle_error
        end
      end

  In `handle_successful_password_reset`, you still need to update the
  database, setting the new value for the password hash, and send an
  email to the user, stating that the password reset was successful.
  """

  use Phauxth.Confirm.Base, ok_log: "password reset"

  def check_key(nil, _, _), do: {:error, "invalid credentials"}
  def check_key(user, key, valid_secs) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_compare(user.reset_token, key) and {:ok, user}
  end
end
