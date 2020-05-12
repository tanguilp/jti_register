defmodule JTIRegister.ETS do
  @default_cleanup_interval 15

  @moduledoc """
  Implementation of the `JTIRegister` behaviour relying on ETS

  Stores the JTIs in an ETS table. It is therefore **not** distributed and not suitable
  when having more than one node.

  Uses monotonic time, so that erroneous server time does not result in JTIs not being deleted.

  ## Options

  - `:cleanup_interval`: the interval between cleanups of the underlying ETS table in seconds.
  Defaults to #{@default_cleanup_interval}

  ## Starting the register

  In your `MyApp.Application` module, add:

      children = [
        JTIRegister.ETS
      ]

  or

      children = [
        {JTIRegister.ETS, cleanup_interval: 30}
      ]

  """

  @behaviour JTIRegister

  use GenServer

  @impl JTIRegister
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl JTIRegister
  def register(jti, exp) do
    expires_in = exp - now()

    exp_monotonic = now_monotonic() + expires_in

    GenServer.cast(__MODULE__, {:add_jti, {jti, exp_monotonic}})
  end

  @impl JTIRegister
  def registered?(jti) do
    now_monotonic = now_monotonic()

    case :ets.lookup(__MODULE__, jti) do
      [{_jti, exp_monotonic}] when exp_monotonic > now_monotonic ->
        true

      _ ->
        false
    end
  end

  @impl GenServer
  def init(opts) do
    schedule_cleanup(opts)

    :ets.new(__MODULE__, [:named_table, :set, :protected])

    {:ok, opts}
  end

  @impl GenServer
  def handle_cast({:add_jti, {jti, exp_monotonic}}, state) do
    :ets.insert(__MODULE__, {jti, exp_monotonic})

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    cleanup()

    schedule_cleanup(state)

    {:noreply, state}
  end

  defp cleanup() do
    match_spec = [
      {
        {:_, :"$1"},
        [{:<, :"$1", now_monotonic()}],
        [true]
      }
    ]

    :ets.select_delete(__MODULE__, match_spec)
  end

  defp schedule_cleanup(state) do
    interval = (state[:cleanup_interval] || @default_cleanup_interval) * 1000

    Process.send_after(self(), :cleanup, interval)
  end

  defp now(), do: System.system_time(:second)
  defp now_monotonic(), do: System.monotonic_time(:second)
end
