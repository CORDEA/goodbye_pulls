defmodule GoodbyePullsWeb.View do
  use GoodbyePullsWeb, :view

  def render("pulls.json", _assigns) do
    %{status: "ok"}
  end
end
