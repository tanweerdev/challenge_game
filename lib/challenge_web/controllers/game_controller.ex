defmodule ChallengeWeb.GameController do
  use ChallengeWeb, :controller

  def index(conn, params) do
    name =
      case params do
        %{"name" => name} -> name
        _ -> generate_random_string(5)
      end

    render(conn, "index.html", name: name)
  end

  # TODO: could have used faker or something. Just to make things simple used below method
  defp generate_random_string(length) do
    "abcdefghijklmnopqrstuvwxyz"
    |> String.split("")
    |> Enum.take_random(length + 1)
    |> Enum.join()
  end
end
