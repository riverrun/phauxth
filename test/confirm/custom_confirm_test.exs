defmodule Phauxth.CustomConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{CustomConfirm, CustomGetUserConfirm, TestToken}

  test "no check for already confirmed" do
    confirmed_email = TestToken.sign(%{"email" => "ray@example.com"}, [])
    %{params: params} = conn(:get, "/confirm?key=" <> confirmed_email) |> fetch_query_params
    {:ok, user} = CustomConfirm.verify(params)
    assert user.email == "ray@example.com"
  end

  test "get_user/2 can be overridden" do
    valid_email = TestToken.sign(%{"email" => "fred+1@example.com"}, [])
    %{params: params} = conn(:get, "/confirm?key=" <> valid_email) |> fetch_query_params
    {:ok, user} = CustomGetUserConfirm.verify(params)
    assert user.email == "fred+1@example.com"
    assert user.current_email == "fred+1@example.com"
  end
end
