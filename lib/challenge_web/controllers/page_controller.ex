defmodule ChallengeWeb.PageController do
  use ChallengeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
