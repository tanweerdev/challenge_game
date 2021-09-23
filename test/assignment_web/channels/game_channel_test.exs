defmodule ChallengeWeb.GameLobbyChannelTest do
  use ChallengeWeb.ChannelCase

  setup do
    {:ok, _payload, socket} =
      ChallengeWeb.UserSocket
      |> socket("game:lobby", %{})
      |> subscribe_and_join(ChallengeWeb.GameLobbyChannel, "game:lobby", %{
        "player" => %{name: "player1", x: 2, y: 2}
      })

    %{socket: socket}
  end

  test "joined channel ", %{socket: socket} do
    assert socket.joined == true
  end

  test "broadcasting player move in the game:lobby", %{socket: socket} do
    push(socket, "movement", %{"player" => %{name: "player1", x: 3, y: 3}})
    assert_broadcast("movement", %{"players" => [%{name: "player1", x: 3, y: 3}]})
  end

  test "broadcasting 2nd player move in the game:lobby", %{socket: socket} do
    push(socket, "movement", %{"player" => %{name: "player2", x: 5, y: 6}})

    assert_broadcast("movement", %{
      "players" => [%{name: "player1", x: 2, y: 2}, %{name: "player2", x: 5, y: 6}]
    })
  end

  test "attacking on the players", %{socket: socket} do
    push(socket, "attack", %{
      "bot" => %{name: "player1", x: 2, y: 2},
      "enemy" => %{"x" => 2, "y" => 1}
    })

    assert_broadcast("movement", %{"players" => [%{name: "player1", x: 2, y: 2}]})
  end
end
