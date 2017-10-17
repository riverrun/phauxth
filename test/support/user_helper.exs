defmodule Phauxth.TestAccounts do

  @users [
    %{id: 1, email: "fred+1@example.com", username: "fred", phone: "55555555555", reset_sent_at: nil,
      role: "user", password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$"), confirmed_at: nil,
      sessions: %{"F25/1mZuBno+Pfu06" => System.system_time(:second),
        "FQcPdSYY9HlaRUKCc" => System.system_time(:second)}},
    %{id: 2, email: "ray@example.com", role: "user", reset_sent_at: nil,
      password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$"), confirmed_at: DateTime.utc_now},
    %{id: 3, email: "froderick@example.com", role: "user", confirmed_at: DateTime.utc_now,
      reset_sent_at: DateTime.utc_now, password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$")},
    %{id: 4, email: "brian@example.com", role: "user", password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$"),
      sessions: %{"FQcPdSYY9HlaRUKCc" => System.system_time(:second)}},
    %{id: 5, email: "igor@example.com", role: "user", reset_sent_at: nil},
    %{id: 6, email: "frank@example.com", password_hash: Argon2.hash_pwd_salt("h4rd2gU3$$")},
    %{id: 7, email: "eddie@example.com", encrypted_password: Argon2.hash_pwd_salt("h4rd2gU3$$")}
  ]
  @chiefs [
    %{id: 1, email: "brian@example.com", role: "admin", password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$")}
  ]

  def get("4a43f849-d9fa-439e-b887-735378009c95"), do: get(4)
  def get(id) when is_binary(id) do
    String.to_integer(id) |> get
  end
  def get(id), do: Enum.at(@users, id - 1)

  def get_by(%{"email" => "fred+1@example.com"}), do: Enum.at(@users, 0)
  def get_by(%{"email" => "ray@example.com"}), do: Enum.at(@users, 1)
  def get_by(%{"email" => "froderick@example.com"}), do: Enum.at(@users, 2)
  def get_by(%{"email" => "igor@example.com"}), do: Enum.at(@users, 4)
  def get_by(%{"email" => "frank@example.com"}), do: Enum.at(@users, 5)
  def get_by(%{"email" => "eddie@example.com"}), do: Enum.at(@users, 6)
  def get_by(%{"username" => "fred"}), do: Enum.at(@users, 0)
  def get_by(%{"phone" => "55555555555"}), do: Enum.at(@users, 0)
  def get_by(%{"email" => _, "role" => "user"}), do: Enum.at(@users, 3)
  def get_by(%{"email" => _, "role" => "admin"}), do: Enum.at(@chiefs, 0)
  def get_by(_), do: nil

end
