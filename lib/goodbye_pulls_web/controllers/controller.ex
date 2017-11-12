defmodule GoodbyePullsWeb.Controller do
  use GoodbyePullsWeb, :controller
  alias GoodbyePullsWeb.{ErrorView, PullRequest, GistHelpers}
  alias Tentacat.{Client, Pulls}
  alias Tentacat.Issues.Comments

  @client Client.new %{
    access_token: Application.get_env(:goodbye_pulls, :github_access_token)
  }

  @gist_template_filename "comment.txt"

  def pulls(conn, params) do
    if is_opened params do
      pr = parse_request params
      url = gist_raw_url Application.get_env(:goodbye_pulls, :gist_id)
      resp = HTTPoison.get url
      handle_gist_response(conn, pr, resp)
    else
      server_error conn
    end
  end

  defp server_error(conn) do
    conn
      |> put_status(500)
      |> render(ErrorView, "500.json", [])
  end

  defp handle_gist_response(conn, pr, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    if succeed_comment? comment(pr, body) do
      if succeed_close? close_pull_request(pr) do
        render(conn, "pulls.json", [])
      else
        server_error conn
      end
    else
      server_error conn
    end
  end

  defp handle_gist_response(conn, _pr, {:ok, _response}), do: server_error conn

  defp handle_gist_response(conn, _pr, {:error, _error}), do: server_error conn

  defp succeed_comment?({code, _body}) when code == 200 or code == 201, do: true

  defp succeed_comment?(_), do: false

  defp succeed_close?({_code, _body}), do: false

  defp succeed_close?(_), do: true

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

  defp gist_raw_url(id) do
    response = GistHelpers.get(@client, id)
    response["files"][@gist_template_filename]["raw_url"]
  end

  defp comment(pr, comment) do
    body = %{
      "body" => comment,
    }
    Comments.create(pr.owner, pr.name, pr.number,
                  body, @client)
  end
end
