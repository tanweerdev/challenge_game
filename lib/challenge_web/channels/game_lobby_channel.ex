defmodule ChallengeWeb.GameLobbyChannel do
  use ChallengeWeb, :channel
  alias Challenge.PlayerServer

  @impl true
  def join("game:lobby", %{"player" => %{"name" => name}}, socket) do
    if !PlayerServer.get(name) do
      # TODO: I could have done a lot better. I hardcoded coz I know the tiles on I am generating on FE
      x = Enum.random(0..5)
      y = Enum.random(0..5)
      PlayerServer.put(name, %{x: x, y: y})
    end

    send(self(), %{"players" => PlayerServer.get()})
    {:ok, assign(socket, :player_name, name)}
  end

  @impl true
  def handle_in("rejoin", %{"player" => %{"name" => name}}, socket) do
    if !PlayerServer.get(name) do
      x = Enum.random(0..5)
      y = Enum.random(0..5)
      PlayerServer.put(name, %{x: x, y: y})
    end

    send(self(), %{"players" => PlayerServer.get()})
    {:noreply, socket}
  end

  @impl true
  def handle_in("movement", move, socket) do
    current_player_dimension = PlayerServer.get(socket.assigns.player_name)

    new_dimension =
      case move do
        "left" ->
          if current_player_dimension.y - 1 >= 0 do
            %{x: current_player_dimension.x, y: current_player_dimension.y - 1}
          else
            current_player_dimension
          end

        "right" ->
          if current_player_dimension.y + 1 <= 9 do
            %{x: current_player_dimension.x, y: current_player_dimension.y + 1}
          else
            current_player_dimension
          end

        "up" ->
          if current_player_dimension.x - 1 >= 0 do
            %{x: current_player_dimension.x - 1, y: current_player_dimension.y}
          else
            current_player_dimension
          end

        "down" ->
          if current_player_dimension.x + 1 <= 9 do
            %{x: current_player_dimension.x + 1, y: current_player_dimension.y}
          else
            current_player_dimension
          end
      end

    PlayerServer.put(socket.assigns.player_name, new_dimension)
    broadcast(socket, "movement", %{"players" => PlayerServer.get()})
    {:noreply, socket}
  end

  @impl true
  def handle_in("attack", _, socket) do
    IO.inspect("asfsdfdklklkls attack")
    cdim = PlayerServer.get(socket.assigns.player_name)
    players = PlayerServer.get()

    Enum.each(players, fn player ->
      for i <- (cdim.x - 1)..(cdim.x + 1) do
        for j <- (cdim.y - 1)..(cdim.y + 1) do
          {player_name, dim} = player

          if dim.x == i && dim.y == j && player_name != socket.assigns.player_name do
            PlayerServer.delete(player_name)
            send(self(), %{"players" => PlayerServer.get()})
            broadcast(socket, "user:" <> player_name <> ":attacked", %{})
          end
        end
      end
    end)

    players = PlayerServer.get()

    {:noreply, socket}
  end

  @impl true
  def handle_info(payload, socket) do
    broadcast(socket, "movement", payload)
    {:noreply, socket}
  end
end
