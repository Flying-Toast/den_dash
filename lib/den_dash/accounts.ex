defmodule DenDash.Accounts do
  import Ecto.Query, warn: false
  alias DenDash.Repo

  alias DenDash.Accounts.User

  defp create_user(caseid) do
    %User{}
    |> User.changeset(%{caseid: caseid, is_regular_employee: false})
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

  def employee?(user) do
    user.is_regular_employee
    or
    super_employee?(user)
  end

  def list_employees() do
    Repo.all(from u in User, where: u.is_regular_employee)
  end

  def make_employee(caseid) do
    Repo.one!(from u in User, where: u.caseid == ^caseid)
    |> User.changeset(%{is_regular_employee: true})
    |> Repo.update!()
  end

  def fire_employee_by_id(id) do
    Repo.get!(User, id)
    |> User.changeset(%{is_regular_employee: false})
    |> Repo.update!()
  end

  def super_employee?(user) do
    user.caseid in Application.fetch_env!(:den_dash, :superemployee_caseids)
  end

  def user_email(user) do
    "#{user.caseid}@case.edu"
  end
end
