defmodule JTIRegister do
  @moduledoc """
  Behaviour for modules implementing JTI registration

  The purpose of a JTI registration service is to prevent replay attacks by checking if the
  token was already used before.

  JTI stands for JWT ID, and identifies a unique JWT security token, but it could work with
  any token having a unique ID. For instance, this is the case for OpenID Connect ID tokens
  whose `nonce` claim is equivalent to a `jti`.

  To avoid allowing use of a JWT in case the server's time changes backward, an implementation
  *should* use monotonic time (see `System.monotonic_time/1`).
  """

  @typedoc """
  A UNIX timestamp
  """
  @type timestamp :: non_neg_integer()

  @doc """
  Registers a `"jti"` with its expiration time `"exp"`
  """
  @callback register(jti :: String.t(), exp :: timestamp()) :: any()

  @doc """
  Returns `true` if a `"jti"` is registered and not expired, `false` otherwise
  """
  @callback registered?(jti :: String.t()) :: boolean()

  @doc """
  Starts a supervised JTI register
  """
  @callback start_link(any()) :: Supervisor.on_start()

  @doc """
  Starts a JTI register (unsupervised)
  """
  @callback start(any()) :: :ok | {:error, any()}

  @optional_callbacks start_link: 1, start: 1
end
