defmodule Phauxth.Confirm.PassReset do
  @moduledoc """
  Confirm a user and reset the password.

  ## Options

  There are two options:

    * identifier - how user is identified in the confirmation request
      * this should be an atom, and the default is :email
    * key_validity - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)

  ## Examples

  Add the following command to the `web/router.ex` file:

      resources "/password_resets", PasswordResetController, only: [:new, :create, :edit, :update]

  Then add the following command to the `password_reset_controller.ex` file:

      plug Phauxth.Confirm.PassReset when action in [:reset_password]

  Or with options:

      plug Phauxth.Confirm.PassReset, [identifier: :phone] when action in [:reset_password]

  """

  use Phauxth.Confirm.Base

  def call(%Plug.Conn{params: %{"password_reset" => params}} = conn,
      {identifier, user_params, key_expiry}) when is_atom(identifier) do
    %{^user_params => user_id, "key" => key, "password" => _password} = params
    check_confirm conn, {identifier, user_id, key, key_expiry, "password reset"}
  end

  def check_key(nil, _, _), do: {:error, "invalid credentials"}
  def check_key(user, key, valid_secs) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_compare(user.reset_token, key) and user
  end
end
