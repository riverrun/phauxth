defmodule Phauxth.TestAccounts do

  @users [
    %{id: 1, email: "fred+1@mail.com", username: "fred", phone: "55555555555",
      role: "user", password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$"), confirmed_at: nil},
    %{id: 2, email: "ray@mail.com", role: "user",
      password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$"), confirmed_at: DateTime.utc_now},
    %{id: 3, email: "froderick@mail.com", role: "user", confirmed_at: DateTime.utc_now,
      password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$")},
    %{id: 4, email: "brian@mail.com", role: "user", password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$")},
    %{id: 5, email: "igor@mail.com", role: "user"},
    %{id: 6, email: "frank@mail.com", password_hash: Argon2.hash_pwd_salt("h4rd2gU3$$")},
    %{id: 7, email: "eddie@mail.com", encrypted_password: Argon2.hash_pwd_salt("h4rd2gU3$$")}
  ]
  @chiefs [
    %{id: 1, email: "brian@mail.com", role: "admin", password_hash: Bcrypt.hash_pwd_salt("h4rd2gU3$$")}
  ]

  def get(id), do: Enum.at(@users, id - 1)

  def get_by(%{"email" => "fred+1@mail.com"}), do: Enum.at(@users, 0)
  def get_by(%{"email" => "ray@mail.com"}), do: Enum.at(@users, 1)
  def get_by(%{"email" => "froderick@mail.com"}), do: Enum.at(@users, 2)
  def get_by(%{"email" => "frank@mail.com"}), do: Enum.at(@users, 5)
  def get_by(%{"email" => "eddie@mail.com"}), do: Enum.at(@users, 6)
  def get_by(%{"username" => "fred"}), do: Enum.at(@users, 0)
  def get_by(%{"phone" => "55555555555"}), do: Enum.at(@users, 0)
  def get_by(%{"email" => _, "role" => "user"}), do: Enum.at(@users, 3)
  def get_by(%{"email" => _, "role" => "admin"}), do: Enum.at(@chiefs, 0)
  def get_by(_), do: nil

end
