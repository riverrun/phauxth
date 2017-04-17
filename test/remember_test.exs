defmodule Phauxth.RememberTest do
  use Phauxth.TestCase
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, Remember, Remember.Utils, SessionHelper, UserHelper}

  @max_age 24 * 60 * 60

  defmodule Endpoint do
    def config(:secret_key_base), do: "abc123"
  end

  setup do
    user = UserHelper.add_user()
    other = UserHelper.add_otp_user()
    conn = conn(:get, "/")
           |> put_private(:phoenix_endpoint, Endpoint)
           |> SessionHelper.sign_conn
           |> Utils.add_cookie(user.id)

    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn

    {:ok, %{conn: conn, newconn: newconn, other: other}}
  end

  test "init function" do
    assert Remember.init([]) == {nil, 86400}
  end

  test "call remember with default options", %{newconn: newconn} do
    newconn = Remember.call(newconn, {Endpoint, @max_age})
    %{current_user: user} = newconn.assigns
    assert user.username == "fred"
    assert user.role == "user"
  end

  test "error log when the cookie is invalid", %{conn: conn} do
    invalid = "SFMyNTY.g3QAAAACZAAEZGF0YWeBZAAGc2lnbmVkbgYAHU1We1sB.mMbd1DOs-1UnE29sTg1O9QC_l1YAHURVe7FsTTsXj88"
    conn = put_resp_cookie(conn, "remember_me", invalid,
     [http_only: true, max_age: 604_800])
    assert capture_log(fn ->
      conn(:get, "/")
      |> recycle_cookies(conn)
      |> SessionHelper.sign_conn
      |> Remember.call({Endpoint, @max_age})
    end) =~ ~s(path=/ user=none message="invalid token")
  end

  test "call remember with no remember cookie" do
    conn = conn(:get, "/")
            |> SessionHelper.sign_conn
            |> Remember.call({Endpoint, @max_age})
    refute conn.assigns[:current_user]
  end

  test "call remember with current_user already set", %{newconn: newconn, other: other} do
    newconn = newconn
              |> put_session(:user_id, other.id)
              |> Authenticate.call({nil, @max_age})
              |> Remember.call({Endpoint, @max_age})
    %{current_user: user} = newconn.assigns
    assert user.id == other.id
    assert user.email == other.email
  end

  test "add cookie", %{conn: conn} do
    remember = conn.resp_cookies["remember_me"]
    assert remember.max_age == 604_800
    assert remember.value =~ "SFMyNTY"
  end

  test "delete cookie" do
  end

  test "output to current_user does not contain password_hash or otp_secret" , %{newconn: newconn} do
    newconn = Remember.call(newconn, {Endpoint, @max_age})
    %{current_user: user} = newconn.assigns
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
