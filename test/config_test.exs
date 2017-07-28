defmodule Phauxth.ConfigTest do
  use ExUnit.Case

  alias Phauxth.Config

  test "generate token salt" do
    assert Config.gen_token_salt() |> byte_size == 8
    assert Config.gen_token_salt(16) |> byte_size == 16
  end

  test "gen_token_salt raises an error if the length is too short" do
    assert_raise ArgumentError, fn -> Config.gen_token_salt(4) end
    assert_raise ArgumentError, fn -> Config.gen_token_salt(7) end
  end

end
