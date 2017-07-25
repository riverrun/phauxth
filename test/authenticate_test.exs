defmodule Phauxth.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phoenix.Token
  alias Phauxth.{Authenticate, SessionHelper, TestAccounts}

  @max_age 24 * 60 * 60

  defmodule TokenEndpoint do
    def config(:secret_key_base), do: "abc123"
  end

  defmodule AbsintheAuthenticate do
    use Phauxth.Authenticate.Base
    import Plug.Conn

    def set_user(user, conn) do
      put_private(conn, :absinthe, %{token: %{current_user: user}})
    end
  end

  def call(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn
    |> put_session(:user_id, id)
    |> Authenticate.call({nil, @max_age, TestAccounts})
  end

  def call_api(token, max_age \\ @max_age) do
    conn(:get, "/")
    |> put_req_header("authorization", token)
    |> Authenticate.call({TokenEndpoint, max_age, TestAccounts})
  end

  def sign_token(id) do
    Token.sign(TokenEndpoint, "user auth", id)
  end

  test "current user in session" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call(10)
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call(1) |> configure_session(drop: true)
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Authenticate.call({nil, @max_age, TestAccounts})
    assert newconn.assigns == %{current_user: nil}
  end

  test "authenticate api sets the current_user" do
    conn = call_api(sign_token(1))
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

  test "authenticate api with invalid token sets the current_user to nil" do
    conn = call_api("garbage")
    assert conn.assigns == %{current_user: nil}
  end

  test "log reports error message for invalid token" do
    assert capture_log(fn ->
      call_api("garbage")
    end) =~ ~s(user=nil message="invalid token")
  end

  test "log reports error message for expired token" do
    assert capture_log(fn ->
      call_api(sign_token(1), -1000)
    end) =~ ~s(user=nil message="expired token")
  end

  test "authenticate api with no token sets the current_user to nil" do
    conn = conn(:get, "/") |> Authenticate.call({TokenEndpoint, @max_age, TestAccounts})
    assert conn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
  end

  test "customized set_user" do
    conn = conn(:get, "/")
           |> put_req_header("authorization", sign_token(1))
           |> AbsintheAuthenticate.call({TokenEndpoint, @max_age, TestAccounts})
    %{token: %{current_user: user}} = conn.private.absinthe
    assert user.email == "fred+1@mail.com"
    assert user.role == "user"
  end

end
