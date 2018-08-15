defmodule Phauxth.Token do
  @moduledoc """
  Behaviour for signing and verifying tokens.
  """

  @type opts :: map | keyword

  @doc """
  Verifies a token.
  """
  @callback verify(binary, opts) :: {:ok, map} | {:error, atom | binary}
end
