defmodule Phauxth.CustomLoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{CustomLogin, TestAccounts}

  test "customize verify to use pass instead of password in params" do
    params = %{"email" => "fred+1@mail.com", "pass" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = CustomLogin.verify(params, TestAccounts)
    assert email == "fred+1@mail.com"
  end

  test "customize check_pass to change algorithm based on hash prefix" do
    params = %{"email" => "frank@mail.com", "pass" => "h4rd2gU3$$"}
    {:ok, %{email: email}} = CustomLogin.verify(params, TestAccounts)
    assert email == "frank@mail.com"
  end

end
