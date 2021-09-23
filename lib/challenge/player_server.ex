defmodule Challenge.PlayerServer do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # TODO: add docs and specs for all public methods in complete codebase
  def put(player, value) do
    GenServer.cast(__MODULE__, {:put, player, value})
  end

  def get(player) do
    GenServer.call(__MODULE__, {:get, player})
  end

  def get() do
    GenServer.call(__MODULE__, {:get})
  end

  def delete(player) do
    GenServer.call(__MODULE__, {:delete, player})
  end

  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:put, player, value}, state) do
    {:noreply, Map.put(state, player, value)}
  end

  def handle_call({:get, player}, _from, state) do
    {:reply, Map.get(state, player), state}
  end

  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:delete, player}, _from, state) do
    new_state = Map.delete(state, player)
    {:reply, new_state, new_state}
  end
end
