defmodule Phauxth.PhxTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Phauxth.PhxToken

  describe "verify/2" do
    test "should allow setting max age" do
      token =
        PhxToken.sign(
          %{"session_id" => "id"},
          signed_at: System.system_time(:seconds) - 14_401
        )

      assert {:error, :expired} = PhxToken.verify(token, [])

      assert {:ok, %{"session_id" => "id"}} = PhxToken.verify(token, max_age: 28_800)
    end
  end
end
