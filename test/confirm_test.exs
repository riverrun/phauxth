defmodule Phauxth.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Confirm, TestAccounts, Token}

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key
    valid_email = Token.sign(conn, %{"email" => "fred+1@mail.com"})
    {:ok, %{conn: conn, valid_email: valid_email}}
  end

  test "confirmation succeeds for valid token", %{conn: conn, valid_email: valid_email} do
    %{params: params} = conn(:get, "/confirm?key=" <> valid_email) |> fetch_query_params
    {:ok, user} = Confirm.verify(conn, params, TestAccounts)
    assert user
  end

  test "confirmation fails for invalid token", %{conn: conn} do
    %{params: params} = conn(:get, "/confirm?key=invalidlink") |> fetch_query_params
    {:error, message} = Confirm.verify(conn, params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "confirmation fails for expired token", %{conn: conn, valid_email: valid_email} do
    %{params: params} = conn(:get, "/confirm?key=" <> valid_email) |> fetch_query_params
    {:error, message} = Confirm.verify(conn, params, TestAccounts, [max_age: -1])
    assert message =~ "Invalid credentials"
  end

  test "confirmation fails for already confirmed account", %{conn: conn} do
    confirmed_email = Token.sign(conn, %{"email" => "ray@mail.com"})
    %{params: params} = conn(:get, "/confirm?key=" <> confirmed_email) |> fetch_query_params
    {:error, message} = Confirm.verify(conn, params, TestAccounts)
    assert message =~ "The user has already been confirmed"
  end

  test "confirmation succeeds with different identifier", %{conn: conn} do
    valid_phone = Token.sign(conn, %{"phone" => "55555555555"})
    %{params: params} = conn(:get, "/confirm?key=" <> valid_phone) |> fetch_query_params
    {:ok, user} = Confirm.verify(conn, params, TestAccounts)
    assert user
  end

end
