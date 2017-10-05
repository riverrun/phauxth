defmodule Phauxth.ChannelTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Phauxth.{Channel, SessionHelper}

  @current_user %{id: 1, email: "ray@example.com", username: "Raymond"}

  defp call(current_user, token_data) do
    conn(:get, "/")
    |> SessionHelper.add_key
    |> assign(:current_user, current_user)
    |> send_resp(200, "")
    |> Channel.call({token_data, [], []})
  end

  defp verify_token(conn) do
    token = conn.assigns.user_token
    Phauxth.Token.verify(conn, token, 600)
  end

  test "token is added for valid current user" do
    {:ok, user} = call(@current_user, &%{"user_id" => &1.email}) |> verify_token
    assert user == %{"user_id" => "ray@example.com"}
  end

  test "no token is added for nil user" do
    conn = call(nil, &%{"user_id" => &1.email})
    refute conn.assigns[:user_token]
  end

  test "token_data is configurable" do
    {:ok, user} = call(@current_user, &%{"user_id" => &1.username}) |> verify_token
    assert user == %{"user_id" => "Raymond"}
  end

  test "can capture a simple term (not a map) for the token_data" do
    {:ok, user} = call(@current_user, &(&1.username)) |> verify_token
    assert user == "Raymond"
  end

  test "raises when token_data is not a function" do
    assert_raise BadFunctionError, fn -> call(@current_user, "fred") end
  end

  test "log reports message when token added" do
    assert capture_log(fn ->
      call(@current_user, &%{"user_id" => &1.email}) |> verify_token
    end) =~ ~s(user=1 message="user token added")
  end

end
