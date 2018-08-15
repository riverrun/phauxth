defmodule Phauxth.Token do
  @moduledoc """
  Behaviour for signing and verifying tokens.
  """

  # maybe just have verify in this behaviour?

  @type opts :: map | keyword

  @doc """
  Signs a token.
  """
  @callback sign(map, opts) :: binary

  @doc """
  Verifies a token.
  """
  @callback verify(binary, opts) :: {:ok, map} | {:error, atom | binary}
end
