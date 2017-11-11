defmodule GoodbyePullsWeb.Controller do
  use GoodbyePullsWeb, :controller
  alias GoodbyePullsWeb.{ErrorView, PullRequest}
  alias Tentacat.{Client, Pulls}
  alias Tentacat.Pulls.Comments

  @client Client.new %{
    access_token: Application.get_env(:goodbye_pulls, :github_access_token)
  }

  def pulls(conn, params) do
    if is_opened(params) do
      pr = parse_request(params)
      render(conn, "pulls.json", [])
    else
      conn
        |> put_status(500)
        |> render(ErrorView, "500.json", [])
    end
  end

  defp is_opened(params) do
    params["action"] == "opened"
  end

  defp parse_request(params) do
    repo = params["pull_request"]["head"]["repo"]

    %PullRequest{
      name: repo["name"],
      owner: repo["owner"]["login"],
      number: params["number"]
    }
  end

  defp close_pull_request(pr) do
    body = %{
      "state" => "close"
    }
    Pulls.update(pr.owner, pr.name, pr.number,
                 body, @client)
  end

  defp comment(pr, comment) do
    body = %{
      "body" => comment,
    }
    Comments.create(pr.owner, pr.name, pr.number,
                  body, @client)
  end
end
