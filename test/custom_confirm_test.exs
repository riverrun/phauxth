defmodule Phauxth.CustomConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{CustomConfirm, TestAccounts, PhxToken}

  setup do
    conn = conn(:get, "/") |> Phauxth.SessionHelper.add_key()
    email = PhxToken.sign(%{"email" => "ray@example.com"}, [])
    {:ok, %{conn: conn, email: email}}
  end

  test "customize verify and get_user", %{conn: conn, email: email} do
    %{params: params} = conn(:get, "/confirm?key=" <> email) |> fetch_query_params
    {:ok, user} = CustomConfirm.verify(params, TestAccounts, conn: conn)
    assert user.email == "ray@example.com"
  end
end
