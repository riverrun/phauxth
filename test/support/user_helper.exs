defmodule Phauxth.TestSessions do
  defmodule TestSession do
    defstruct [:id, :user_id]
  end

  def sessions do
    %{
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
        username: "fred"
      },
      "2" => %TestUser{
        id: "2",
        email: "ray@example.com",
        confirmed_at: DateTime.utc_now()
      },
      "3" => %TestUser{
        id: "3",
        email: "froderick@example.com",
        confirmed_at: DateTime.utc_now(),
        reset_sent_at: DateTime.utc_now()
      },
      "4" => %TestUser{
        id: "4",
        email: "igor@example.com"
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

  def get_by(%{"user_id" => user_id}) do
    users() |> Map.values() |> Enum.find(&(&1.id == user_id))
  end
end
