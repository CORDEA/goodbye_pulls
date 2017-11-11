defmodule GoodbyePullsWeb.Controller do
  use GoodbyePullsWeb, :controller

  def pulls(conn, params) do
    render(conn, "pulls.json", [])
  end
end
