defmodule Phauxth.Authenticate.TokenTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Phauxth.{AuthenticateToken, PhxToken, SessionHelper, TestUsers}

  @token_opts %{user_context: TestUsers, log_meta: [], opts: []}

  defp add_token(id, token \\ nil, key_opts \\ []) do
    conn = conn(:get, "/") |> SessionHelper.add_key()
    token = token || PhxToken.sign(%{"session_id" => id}, key_opts)
    put_req_header(conn, "authorization", token)
  end

  defp call_api(id, token \\ nil, verify_opts \\ []) do
    opts = %{user_context: TestUsers, log_meta: [], opts: verify_opts}
    id |> add_token(token, []) |> AuthenticateToken.call(opts)
  end

  test "authenticate api sets the current_user" do
    conn = call_api("1111")
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "authenticate api with invalid token sets the current_user to nil" do
    conn = call_api("1111", "garbage")
    assert conn.assigns == %{current_user: nil}
  end

  test "log reports error message for invalid token" do
    assert capture_log(fn ->
             call_api("1111", "garbage")
           end) =~ ~s(user=nil message=invalid)
  end

  test "log reports error message for expired token" do
    assert capture_log(fn ->
             call_api("1111", nil, max_age: -1)
           end) =~ ~s(user=nil message=expired)
  end

  test "authenticate api with no token sets the current_user to nil" do
    conn = conn(:get, "/") |> AuthenticateToken.call(@token_opts)
    assert conn.assigns == %{current_user: nil}
  end

  test "customized set_user - absinthe example" do
    conn = "1111" |> add_token() |> Phauxth.AbsintheAuthenticate.call(@token_opts)
    %{context: %{current_user: user}} = conn.private.absinthe
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "key options passed on to the token module" do
    conn = add_token("3333", nil, key_length: 20)
    opts_1 = %{user_context: TestUsers, log_meta: [], opts: [key_length: 20]}
    opts_2 = %{user_context: TestUsers, log_meta: [], opts: []}
    conn = AuthenticateToken.call(conn, opts_1)
    %{current_user: user} = conn.assigns
    assert user.email == "froderick@example.com"
    conn = AuthenticateToken.call(conn, opts_2)
    assert conn.assigns == %{current_user: nil}
  end

  test "token stored in a cookie" do
    token = PhxToken.sign(%{"session_id" => "1111"}, [])

    conn =
      conn(:get, "/")
      |> put_req_cookie("access_token", token)
      |> fetch_cookies
      |> Phauxth.AuthenticateTokenCookie.call(@token_opts)

    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
  end
end
