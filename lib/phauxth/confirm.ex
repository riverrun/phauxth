defmodule Phauxth.Confirm do
  @moduledoc """
  Module to provide user confirmation.

  This Plug can be used to provide user confirmation by email, phone,
  or any other method.

  ## Options

  There are two options:

    * identifier - how the user is identified in the confirmation request
      * this should be an atom, and the default is :email
    * key_validity - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)

  ## Examples

  Add the following command to the `web/router.ex` file:

      get "/new", ConfirmController, :new

  Then add the following to the `confirm_controller.ex` file:

      plug Phauxth.Confirm

  Or with options:

      plug Phauxth.Confirm, [key_validity: 20]

  """

  use Phauxth.Confirm.Base

  @doc """
  Generate a confirmation token.
  """
  def gen_token do
    :crypto.strong_rand_bytes(24) |> Base.url_encode64
  end

  @doc """
  Generate a link containing a user-identifier and the confirmation token.
  """
  def gen_link(user_id, key, identifier \\ :email) do
    "#{identifier}=#{URI.encode_www_form(user_id)}&key=#{key}"
  end
end
