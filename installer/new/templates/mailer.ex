defmodule <%= base %>.Mailer do
  @moduledoc """
  A module for sending emails.

  These functions are used for email confirmation and password resetting.

  You need to complete these functions with the email library / module of
  your choice.
  """

  @doc """
  An email with a confirmation link in it.
  """
  def ask_confirm(_email, link) do
    confirm_url = "http://www.example.com/users/confirm#{link}"
    confirm_url
  end

  @doc """
  An email with a link to reset the password.
  """
  def ask_reset(_email, link) do
    confirm_url = "http://www.example.com/password_resets/edit?#{link}"
    confirm_url
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def receipt_confirm(email) do
    email
  end
end
