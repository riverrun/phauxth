defmodule Phauxth.TestSessions do
  defmodule TestSession do
    defstruct [:id, :user_id]
  end

  def sessions do
    %{
      123 => %TestSession{id: 123, user_id: "1"},
      "1111" => %TestSession{id: "1111", user_id: "1"},
      "2222" => %TestSession{id: "2222", user_id: "2"},
      "3333" => %TestSession{id: "3333", user_id: "3"},
      "4444" => %TestSession{id: "4444", user_id: "4"},
      "5555" => %TestSession{id: "5555", user_id: "4a43f849-d9fa-439e-b887-735378009c95"}
    }
  end
end

defmodule Phauxth.TestUsers do
  defmodule TestUser do
    defstruct [
      :id,
      :email,
      :username,
      :password_hash,
      :confirmed_at,
      :reset_sent_at,
      role: "user",
      password_hash: "password hash"
    ]
  end

  alias Phauxth.TestSessions

  def users do
    %{
      "1" => %TestUser{
        id: "1",
        email: "fred+1@example.com",
        username: "fred",
        password_hash: Argon2.hash_pwd_salt("h4rd2gU3$$")
      },
      "2" => %TestUser{
        id: "2",
        email: "ray@example.com",
        confirmed_at: DateTime.utc_now(),
        password_hash: Argon2.hash_pwd_salt("h4rd2gU3$$")
      },
      "3" => %TestUser{
        id: "3",
        email: "froderick@example.com",
        confirmed_at: DateTime.utc_now(),
        reset_sent_at: DateTime.utc_now()
      },
      "4" => %TestUser{
        id: "4",
        email: "igor@example.com",
        confirmed_at: DateTime.utc_now()
      },
      "4a43f849-d9fa-439e-b887-735378009c95" => %TestUser{
        id: "4a43f849-d9fa-439e-b887-735378009c95",
        email: "brian@example.com"
      }
    }
  end

  def get_by(%{"session_id" => id}) do
    with %{user_id: user_id} <- Map.get(TestSessions.sessions(), id),
         do: users()[user_id]
  end

  def get_by(%{"email" => email}) do
    users() |> Map.values() |> Enum.find(&(&1.email == email))
  end

  def get_by(%{"username" => username}) do
    users() |> Map.values() |> Enum.find(&(&1.username == username))
  end

  def get_by(%{"user_id" => user_id}) do
    users() |> Map.values() |> Enum.find(&(&1.id == user_id))
  end

  def create_session(%{user_id: user_id}) do
    case TestSessions.sessions() |> Map.values() |> Enum.find(&(&1.user_id == user_id)) do
      nil -> {:error, "No user found"}
      session -> {:ok, session}
    end
  end
end

defmodule Phauxth.OtherTestUsers do
  def users do
    %{
      "1" => %{
        id: "1111",
        email: "deirdre@example.com",
        confirmed_at: nil,
        password_hash: Argon2.hash_pwd_salt("h4rd2gU3$$")
      }
    }
  end

  def get_by(%{"session_id" => "1111"}), do: users()["1"]
  def get_by(%{"email" => "deirdre@example.com"}), do: users()["1"]
end
