defmodule GoodbyePullsWeb.GistHelpers do
  alias Tentacat

  def get(client, id) do
    Tentacat.get("gists/#{id}", client)
  end
end
