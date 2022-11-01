defmodule DenDash.Accounts do
  import Ecto.Query, warn: false
  alias DenDash.Repo

  alias DenDash.Accounts.User

  defp create_user(caseid) do
    %User{}
    |> User.changeset(%{caseid: caseid})
    |> Repo.insert!()
  end

  def get_or_create_user(caseid) do
    maybe_user = Repo.one(from u in User, where: u.caseid == ^caseid)

    if maybe_user != nil do
      maybe_user
    else
      create_user(caseid)
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
