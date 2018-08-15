defmodule Phauxth.UserMessagesTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.Config

  defmodule CustomUserMessages do
    use Phauxth.UserMessages.Base
    def default_error, do: "guv'nor says you gotta wear a whistle to come in 'ere, me old china"
  end

  test "can customize the user messages" do
    assert Config.user_messages().default_error() =~ "Invalid credentials"
    assert CustomUserMessages.default_error() =~ "wear a whistle to come in 'ere, me old china"
  end
end
