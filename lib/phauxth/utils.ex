defmodule Phauxth.Utils do
  @moduledoc false

  @variant10 2
  @uuid_v4 4

  def uuid4 do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = :crypto.strong_rand_bytes(16)

    <<u0::48, @uuid_v4::4, u1::12, @variant10::2, u2::62>>
    |> Base.encode16(case: :lower)
    |> format()
  end

  defp format(<<u0::binary-8, u1::binary-4, u2::binary-4, u3::binary-4, u4::binary-12>>) do
    u0 <> "-" <> u1 <> "-" <> u2 <> "-" <> u3 <> "-" <> u4
  end
end
