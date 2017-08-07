defmodule <%= base %>.Message do
  @moduledoc """
  A module for sending messages, by email or phone, to the user.

  These functions are used for user confirmation and password resetting.

  You need to complete these functions with the email / phone library of
  your choice.
  """

  @doc """
  A message with a confirmation link in it.
  """
  def confirm_request(address, key) do
    confirm_url = "http://www.example.com/users/confirm?key=#{key}"
    {address, confirm_url}
  end

  @doc """
  A message with a link to reset the password.
  """
  def reset_request(address, key) do
    confirm_url = "http://www.example.com/password_resets/edit?key=#{key}"
    {address, confirm_url}
  end

  @doc """
  A message acknowledging that the account has been successfully confirmed.
  """
  def confirm_success(address) do
    address
  end

  @doc """
  A message acknowledging that the account has been successfully resetted.
  """
  def reset_success(address) do
    address
  end
end
