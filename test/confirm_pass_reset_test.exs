defmodule Phauxth.Confirm.PassResetTest do
  use Phauxth.TestCase
  use Plug.Test

  import Ecto.Changeset
  alias Comeonin.Bcrypt
  alias Phauxth.{TestRepo, TestUser, UserHelper}
  alias Phauxth.Confirm.PassReset

  @db [repo: TestRepo, user_schema: TestUser]

  setup do
    attrs = %{email: "frank@mail.com", role: "user", password: "h4rd2gU3$$",
      confirmed_at: Ecto.DateTime.utc}
    UserHelper.add_reset_user(attrs)
    :ok
  end

  def login(name, password, identifier \\ :email, user_params \\ "email") do
    params = %{user_params => name, "password" => password}
    Phauxth.Login.verify(params, [identifier: identifier] ++ @db)
  end

  def call_reset(password, opts) do
    params = %{"email" => "frank@mail.com",
      "key" => "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw",
      "password" => password}
    PassReset.verify(params, opts ++ @db) |> update_repo(password)
  end

  def update_repo({:error, message}, _), do: {:error, message}
  def update_repo({:ok, user}, password) do
    UserHelper.reset_password(user, password)
    {:ok, user}
  end

  def password_changed(password) do
    user = TestRepo.get_by(TestUser, email: "frank@mail.com")
    Bcrypt.checkpw(password, user.password_hash)
  end

  test "reset password succeeds" do
    password = "my N1pples expl0de with the light!"
    {:ok, _user} = call_reset(password, [identifier: :email, key_validity: 60])
    assert password_changed(password)
  end

  test "reset password fails with expired token" do
    password = "C'est bon, la vie"
    {:error, message} = call_reset(password, [identifier: :email, key_validity: 0])
    assert message =~ "Invalid credentials"
    refute password_changed(password)
  end

  test "reset password fails when reset_sent_at is nil" do
    user = TestRepo.get_by(TestUser, email: "frank@mail.com")
    change(user, %{reset_sent_at: nil})
    |> Phauxth.TestRepo.update
    {:error, message} = call_reset("password", [identifier: :email, key_validity: 60])
    assert message =~ "Invalid credentials"
    refute password_changed("password")
  end

end
