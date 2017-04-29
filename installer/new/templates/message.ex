defmodule <%= base %>.Message do
  @moduledoc """
  A module for sending emails. # modify this so is can be used for phone messages as well

  These functions are used for email confirmation and password resetting.

  You need to complete these functions with the email library / module of
  your choice.
  """

  @doc """
  An email with a confirmation link in it.
  """
  def confirm_request(_email, link) do
    confirm_url = "http://www.example.com/users/confirm#{link}"
    confirm_url
  end

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(_email, link) do
    confirm_url = "http://www.example.com/password_resets/edit?#{link}"
    confirm_url
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def confirm_success(email) do
    email
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def reset_success(email) do
    email
  end
end
