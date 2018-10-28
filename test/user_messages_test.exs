defmodule Phauxth.UserMessagesTest do
  use ExUnit.Case
  use Plug.Test

  defmodule CustomUserMessages do
    use Phauxth.UserMessages.Base
    def need_confirm, do: "guv'nor says you gotta wear a whistle to come in 'ere, me old china"
  end

  test "can customize the user messages" do
    assert CustomUserMessages.need_confirm() =~ "wear a whistle to come in 'ere, me old china"
    assert CustomUserMessages.default_error() =~ "Invalid credentials"
    assert CustomUserMessages.invalid_token() =~ "Invalid token"
  end
end
