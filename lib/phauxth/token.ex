defmodule Phauxth.Token do
  @moduledoc """
  Behaviour for signing and verifying tokens.

  See Phauxth.PhxToken for an example implementation of this behaviour
  using Phoenix tokens.
  """

  @type data :: map | keyword | binary | integer
  @type opts :: keyword

  @doc """
  Signs a token.
  """
  @callback sign(data, opts) :: binary

  @doc """
  Verifies a token.
  """
  @callback verify(binary, opts) :: {:ok, map} | {:error, atom | binary}
end
