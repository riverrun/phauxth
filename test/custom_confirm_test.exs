defmodule Phauxth.CustomConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{CustomConfirm, PhxToken}

  test "no check for already confirmed" do
    confirmed_email = PhxToken.sign(%{"email" => "ray@example.com"}, [])
    %{params: params} = conn(:get, "/confirm?key=" <> confirmed_email) |> fetch_query_params
    {:ok, user} = CustomConfirm.verify(params)
    assert user.email == "ray@example.com"
  end
end
