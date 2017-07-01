defmodule Phauxth.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Confirm, TestAccounts}

  @valid_link "email=fred%2B1%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @confirmed_link "email=ray%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @incomplete_link "email=wrong%40mail.com"

  test "confirmation succeeds for valid token" do
    %{params: params} = conn(:get, "/confirm?" <> @valid_link) |> fetch_query_params
    {:ok, user} = Confirm.verify(params, TestAccounts)
    assert user
  end

  test "confirmation fails for invalid token" do
    %{params: params} = conn(:get, "/confirm?" <> @invalid_link) |> fetch_query_params
    {:error, message} = Confirm.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "confirmation fails for expired token" do
    %{params: params} = conn(:get, "/confirm?" <> @valid_link) |> fetch_query_params
    {:error, message} = Confirm.verify(params, TestAccounts, [key_validity: 0])
    assert message =~ "Invalid credentials"
  end

  test "invalid link error" do
    %{params: params} = conn(:get, "/confirm?" <> @incomplete_link) |> fetch_query_params
    {:error, message} = Confirm.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "confirmation fails for already confirmed account" do
    %{params: params} = conn(:get, "/confirm?" <> @confirmed_link) |> fetch_query_params
    {:error, message} = Confirm.verify(params, TestAccounts)
    assert message =~ "Invalid credentials"
  end

  test "confirmation succeeds with custom identifier" do
    phone_link = "phone=55555555555&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
    %{params: params} = conn(:get, "/confirm?" <> phone_link) |> fetch_query_params
    {:ok, user} = Confirm.verify(params, TestAccounts, [identifier: :phone])
    assert user
  end

  test "check time" do
    assert Phauxth.Confirm.Base.check_time(Ecto.DateTime.utc, 60)
    refute Phauxth.Confirm.Base.check_time(Ecto.DateTime.utc, -60)
    refute Phauxth.Confirm.Base.check_time(nil, 60)
  end

  test "gen_token creates a token 32 bytes long" do
    assert Phauxth.Confirm.gen_token() |> byte_size == 32
  end

  test "gen_link" do
    key = "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
    link = Phauxth.Confirm.gen_link("fred@mail.com", key)
    assert link =~ "email=fred%40mail.com&key="
    assert :binary.match(link, [key]) == {26, 32}
  end

  test "gen_link with custom identifier" do
    key = "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
    link = Phauxth.Confirm.gen_link("55555555555", key, :phone)
    assert link =~ "phone=55555555555&key="
    assert :binary.match(link, [key]) == {22, 32}
  end
end
