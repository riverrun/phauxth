defmodule Phauxth.TokenAuthenticateTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Authenticate, SessionHelper, TestAccounts, Token}

  @max_age 4 * 60 * 60
  @token_opts {:token, @max_age, TestAccounts, []}

  defp add_token(id, token \\ nil, key_opts \\ []) do
    conn = conn(:get, "/") |> SessionHelper.add_key
    put_req_header(conn, "authorization", token || Token.sign(conn, id, key_opts))
  end

  defp call_api(id, token \\ nil, max_age \\ @max_age) do
    opts = {:token, max_age, TestAccounts, []}
    add_token(id, token)
    |> Authenticate.call({opts, []})
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
    conn = conn(:get, "/") |> Authenticate.call({@token_opts, []})
    assert conn.assigns == %{current_user: nil}
  end

  test "customized set_user - absinthe example" do
    conn = add_token(1) |> Phauxth.AbsintheAuthenticate.call({@token_opts, []})
    %{token: %{current_user: user}} = conn.private.absinthe
    assert user.email == "fred+1@example.com"
    assert user.role == "user"
  end

  test "customized check_token" do
    conn = add_token(1) |> Phauxth.CustomToken.call({@token_opts, []})
    %{current_user: user} = conn.assigns
    assert user.email == "froderick@example.com"
  end

  test "key options passed on to the Token module" do
    conn = add_token(3, nil, [key_length: 20])
    opts_1 = {:token, @max_age, TestAccounts, [key_length: 20]}
    opts_2 = {:token, @max_age, TestAccounts, []}
    conn = Authenticate.call(conn, {opts_1, []})
    %{current_user: user} = conn.assigns
    assert user.email == "froderick@example.com"
    conn = Authenticate.call(conn, {opts_2, []})
    assert conn.assigns == %{current_user: nil}
  end

end
