defmodule Phauxth.TestAccounts do
  @users [
    %{
      id: 1,
      email: "fred+1@example.com",
      username: "fred",
      phone: "55555555555",
      reset_sent_at: nil,
      role: "user",
      password_hash: "password hash",
      confirmed_at: nil,
      sessions: %{
        "F25/1mZuBno+Pfu06" => System.system_time(:second),
        "Fc0k6ku4lm61uO7pnBKreWoHo" => System.system_time(:second)
      }
    },
    %{
      id: 2,
      email: "ray@example.com",
      role: "user",
      reset_sent_at: nil,
      password_hash: "password hash",
      confirmed_at: DateTime.utc_now()
    },
    %{
      id: 3,
      email: "froderick@example.com",
      role: "user",
      confirmed_at: DateTime.utc_now(),
      reset_sent_at: DateTime.utc_now(),
      password_hash: "password hash"
    },
    %{
      id: 4,
      email: "brian@example.com",
      role: "user",
      password_hash: "password hash",
      sessions: %{"FQcPdSYY9HlaRUKCc" => System.system_time(:second)}
    },
    %{id: 5, email: "igor@example.com", role: "user", reset_sent_at: nil},
    %{id: 6, email: "frank@example.com", password_hash: "password hash"}
  ]
  @chiefs [
    %{
      id: 1,
      email: "brian@example.com",
      role: "admin",
      password_hash: "password hash"
    }
  ]

  def get_by(%{"session_id" => "F25/1mZuBno+Pfu06"}), do: Enum.at(@users, 0)
  def get_by(%{"session_id" => "Fc0k6ku4lm61uO7pnBKreWoHo"}), do: Enum.at(@users, 0)
  def get_by(%{"session_id" => "FQcPdSYY9HlaRUKCc4"}), do: Enum.at(@users, 3)
  def get_by(%{"user_id" => 1}), do: Enum.at(@users, 0)
  def get_by(%{"user_id" => 3}), do: Enum.at(@users, 2)
  def get_by(%{"user_id" => 4}), do: Enum.at(@users, 3)
  def get_by(%{"user_id" => "4a43f849-d9fa-439e-b887-735378009c95"}), do: Enum.at(@users, 3)
  def get_by(%{"email" => "fred+1@example.com"}), do: Enum.at(@users, 0)
  def get_by(%{"email" => "ray@example.com"}), do: Enum.at(@users, 1)
  def get_by(%{"email" => "froderick@example.com"}), do: Enum.at(@users, 2)
  def get_by(%{"email" => "igor@example.com"}), do: Enum.at(@users, 4)
  def get_by(%{"email" => "frank@example.com"}), do: Enum.at(@users, 5)
  def get_by(%{"username" => "fred"}), do: Enum.at(@users, 0)
  def get_by(%{"phone" => "55555555555"}), do: Enum.at(@users, 0)
  def get_by(%{"email" => _, "role" => "user"}), do: Enum.at(@users, 3)
  def get_by(%{"email" => _, "role" => "admin"}), do: Enum.at(@chiefs, 0)
  def get_by(_), do: nil
end
