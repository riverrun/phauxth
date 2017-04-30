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

      get "/update", ConfirmController, :update

  Then add the following to the `confirm_controller.ex` file:

      plug Phauxth.Confirm

  Or with options:

      plug Phauxth.Confirm, [key_validity: 20]

  """

  use Phauxth.Confirm.Base

  @doc """
  Generate a confirmation token and a link containing the user-identifier
  and the token.

  The link is used to create the url that the user needs to follow to
  complete the confirmation process.

  ## Examples

  To create a key and link for email confirmation:

      Phauxth.Confirm.gen_token_link("fred@mail.com")

  To create a key and link for phone confirmation:

      Phauxth.Confirm.gen_token_link("83749374983", :phone)

  """
  def gen_token_link(user, identifier \\ :email) do
    key = :crypto.strong_rand_bytes(24) |> Base.url_encode64
    {key, "#{identifier}=#{URI.encode_www_form(user)}&key=#{key}"}
  end
end
