defmodule GoodbyePullsWeb.PullRequest do
  @enforce_keys [:name, :owner, :number]
  defstruct [:name, :owner, :number]
end
