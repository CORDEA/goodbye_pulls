defmodule GoodbyePullsWeb.Router do
  use GoodbyePullsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GoodbyePullsWeb do
    pipe_through :api
    post "/pulls", Controller, :pulls
  end
end
