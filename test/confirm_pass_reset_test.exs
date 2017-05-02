defmodule Phauxth.Confirm.PassResetTest do
  use Phauxth.TestCase
  use Plug.Test

  import Ecto.Changeset
  alias Comeonin.Bcrypt
  alias Phauxth.{TestRepo, TestUser, UserHelper}
  alias Phauxth.Confirm.PassReset

  setup do
    attrs = %{email: "frank@mail.com", role: "user", password: "h4rd2gU3$$",
      confirmed_at: Ecto.DateTime.utc}
    UserHelper.add_reset_user(attrs)
    :ok
  end

  def call_reset(password, opts) do
    conn(:post, "/password_reset",
         %{"password_reset" => %{"email" => "frank@mail.com",
                       "key" => "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw",
                       "password" => password}})
    |> PassReset.call(opts)
    |> update_repo(password)
  end

  def update_repo(%Plug.Conn{private: %{phauxth_error: _}} = conn, _), do: conn
  def update_repo(%Plug.Conn{private: %{phauxth_user: user}} = conn, password) do
    UserHelper.reset_password(user, password)
    conn
  end

  def password_changed(password) do
    user = TestRepo.get_by(TestUser, email: "frank@mail.com")
    Bcrypt.checkpw(password, user.password_hash)
  end

  test "init function" do
    assert PassReset.init([]) == {:email, "email", 60}
  end

  test "reset password succeeds" do
    password = "my N1pples expl0de with the light!"
    conn = call_reset(password, {:email, "email", 60})
    assert password_changed(password)
    assert conn.private.phauxth_user
  end

  test "reset password fails with expired token" do
    password = "C'est bon, la vie"
    conn = call_reset(password, {:email, "email", 0})
    refute password_changed(password)
    assert conn.private.phauxth_error =~ "Invalid credentials"
  end

  test "reset password fails when reset_sent_at is nil" do
    user = TestRepo.get_by(TestUser, email: "frank@mail.com")
    change(user, %{reset_sent_at: nil})
    |> Phauxth.TestRepo.update
    conn = call_reset("password", {:email, "email", 60})
    assert conn.private.phauxth_error =~ "Invalid credentials"
  end

end
