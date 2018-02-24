defmodule Phauxth.AuthenticateTokenTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Phauxth.{SessionHelper, TestAccounts, Token, AuthenticateToken}

  @max_age 4 * 60 * 60
  @token_opts {{@max_age, TestAccounts, []}, []}

  defp add_token(id, token \\ nil, key_opts \\ []) do
    conn = conn(:get, "/") |> SessionHelper.add_key()
    token = token || Token.sign(conn, %{"user_id" => id}, key_opts)
    put_req_header(conn, "authorization", token)
  end

  defp call_api(id, token \\ nil, max_age \\ @max_age) do
    opts = {{max_age, TestAccounts, []}, []}

    add_token(id, token)
    |> AuthenticateToken.call(opts)
  end

  test "authenticate api sets the current_user" do
    conn = call_api(1)
    %{current_user: user} = conn.assigns
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "authenticate api with invalid token sets the current_user to nil" do
    conn = call_api(1, "garbage")
    assert conn.assigns == %{current_user: nil}
  end

  test "log reports error message for invalid token" do
    assert capture_log(fn ->
             call_api(1, "garbage")
           end) =~ ~s(user=nil message="invalid token")
  end

  test "log reports error message for expired token" do
    assert capture_log(fn ->
             call_api(1, nil, -1000)
           end) =~ ~s(user=nil message="expired token")
  end

  test "authenticate api with no token sets the current_user to nil" do
    conn = conn(:get, "/") |> AuthenticateToken.call(@token_opts)
    assert conn.assigns == %{current_user: nil}
  end

  test "customized set_user - absinthe example" do
    conn = add_token(1) |> Phauxth.AbsintheAuthenticate.call(@token_opts)
    %{context: %{current_user: user}} = conn.private.absinthe
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "key options passed on to the Token module" do
    conn = add_token(3, nil, key_length: 20)
    opts_1 = {{@max_age, TestAccounts, [key_length: 20]}, []}
    opts_2 = {{@max_age, TestAccounts, []}, []}
    conn = AuthenticateToken.call(conn, opts_1)
    %{current_user: user} = conn.assigns
    assert user.email == "froderick@example.com"
    conn = AuthenticateToken.call(conn, opts_2)
    assert conn.assigns == %{current_user: nil}
  end
end
