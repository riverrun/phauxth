defmodule Phauxth.OtpTest do
  use Phauxth.TestCase
  use Plug.Test

  import Ecto.Changeset
  alias Phauxth.{TestRepo, TestUser, UserHelper}

  setup context do
    attrs = %{email: "brian@mail.com", role: "user", password: "h4rd2gU3$$",
      otp_required: true, otp_secret: "MFRGGZDFMZTWQ2LK", otp_last: 0}
    %{id: user_id} = UserHelper.add_user(attrs)
    otp_last = context[:last] || 0
    update_repo(user_id, otp_last)
    {:ok, %{user_id: user_id}}
  end

  def call(user, opts) do
    conn(:post, "/twofactor", %{"user" => user})
    |> Phauxth.Otp.call(opts)
  end

  def update_repo(user_id, otp_last) do
    TestRepo.get(TestUser, user_id)
    |> change(%{otp_last: otp_last})
    |> TestRepo.update!
  end

  test "init function" do
    assert Phauxth.Otp.init([]) == []
  end

  test "check hotp with default options", %{user_id: user_id} do
    user = %{"hotp" => "816065", "id" => user_id}
    conn = call(user, [])
    %{id: id, otp_last: otp_last} = conn.private[:phauxth_user]
    assert id == user_id
    assert otp_last == 2
    refute conn.private[:phauxth_error]
    fail = %{"hotp" => "816066", "id" => user_id}
    conn = call(fail, [])
    assert conn.private[:phauxth_error]
  end

  @tag last: 18
  test "check hotp with updated last", %{user_id: user_id} do
    user = %{"hotp" => "088239", "id" => user_id}
    conn = call(user, [])
    %{id: id, otp_last: otp_last} = conn.private[:phauxth_user]
    assert id == user_id
    assert otp_last == 19
    assert conn.private[:phauxth_user]
    refute conn.private[:phauxth_error]
    fail = %{"hotp" => "088238", "id" => user_id}
    conn = call(fail, [])
    assert conn.private[:phauxth_error]
  end

  test "check totp with default options", %{user_id: user_id} do
    token = Comeonin.Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    conn = call(user, [])
    assert conn.private[:phauxth_user]
    refute conn.private[:phauxth_error]
  end

  test "disallow totp check with same token", %{user_id: user_id} do
    token = Comeonin.Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    conn = call(user, [])
    %{otp_last: otp_last} = conn.private[:phauxth_user]
    update_repo(user_id, otp_last)
    conn = call(user, [])
    assert conn.private[:phauxth_error]
  end

  test "disallow totp check with earlier token that is still valid", %{user_id: user_id} do
    token = Comeonin.Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    conn = call(user, [])
    %{otp_last: otp_last} = conn.private[:phauxth_user]
    update_repo(user_id, otp_last)
    new_token = Comeonin.Otp.gen_hotp("MFRGGZDFMZTWQ2LK", otp_last - 1)
    user = %{"totp" => new_token, "id" => user_id}
    conn = call(user, [])
    assert conn.private[:phauxth_error]
  end

  test "output to current_user does not contain password_hash or otp_secret", %{user_id: user_id} do
    user = %{"hotp" => "816065", "id" => user_id}
    conn = call(user, [])
    user = conn.private[:phauxth_user]
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
