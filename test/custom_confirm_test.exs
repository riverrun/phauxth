defmodule Phauxth.CustomConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Config, CustomConfirm, TestAccounts}
  alias Phoenix.Token

  @endpoint Config.endpoint()
  @user_salt Config.token_salt()

  test "no check for already confirmed" do
    confirmed_email = Token.sign(@endpoint, @user_salt, %{"email" => "ray@example.com"})
    %{params: params} = conn(:get, "/confirm?key=" <> confirmed_email) |> fetch_query_params
    {:ok, user} = CustomConfirm.verify(params, TestAccounts)
    assert user.email == "ray@example.com"
  end
end
