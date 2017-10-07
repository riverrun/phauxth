defmodule Phauxth.ChannelTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Channel, SessionHelper}

  @current_user %{id: 1, email: "ray@example.com", username: "Raymond"}

  defp call(current_user, token_id) do
    conn(:get, "/")
    |> SessionHelper.add_key
    |> assign(:current_user, current_user)
    |> send_resp(200, "")
    |> Channel.call({token_id, [], []})
  end

  defp verify_token(conn) do
    token = conn.assigns.user_token
    Phauxth.Token.verify(conn, token, 600)
  end

  test "token is added for valid current user" do
    {:ok, user} = call(@current_user, :email) |> verify_token
    assert user == %{"user_id" => "ray@example.com"}
  end

  test "no token is added for nil user" do
    conn = call(nil, :email)
    refute conn.assigns[:user_token]
  end

  test "token_id is configurable" do
    {:ok, user} = call(@current_user, :username) |> verify_token
    assert user == %{"user_id" => "Raymond"}
  end

  test "log reports message when token added" do
    assert capture_log(fn ->
      call(@current_user, :email) |> verify_token
    end) =~ ~s(user=1 message="user token added")
  end

end
