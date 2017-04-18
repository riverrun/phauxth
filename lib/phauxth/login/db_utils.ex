defmodule Phauxth.Login.DB_Utils do
  @moduledoc """
  Helper functions to be used with Ecto.
  """

  import Ecto.Changeset

  @doc """
  Add the password hash to the changeset.
  """
  def add_password_hash(user, %{"password" => password}) do
    valid_password?(password, 8) |> add_hash_changeset(user)
  end
  def add_password_hash(user, %{password: password}) do
    valid_password?(password, 8) |> add_hash_changeset(user)
  end
  def add_password_hash(user, _), do: user

  defp valid_password?(password, min_len) when is_binary(password) do
    String.length(password) >= min_len and
      {:ok, password} || {:error, "The password is too short. At least #{min_len} characters."}
  end
  defp valid_password?(_, _), do: {:error, "The password should be a string"}

  defp add_hash_changeset({:ok, password}, user) do
    change(user, %{password_hash: Comeonin.Bcrypt.hashpwsalt(password)})
  end
  defp add_hash_changeset({:error, message}, user) do
    change(user, %{password: ""}) |> add_error(:password, message)
  end
end
