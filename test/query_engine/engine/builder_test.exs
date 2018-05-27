defmodule QueryEngine.Engine.Builder.Test do
  use QueryEngine.ModelCase, async: true
  doctest QueryEngine.Engine.Builder

  alias QueryEngine.Engine.Builder
  alias QueryEngine.Interface.Request

  alias QueryEngine.Query.Filter
  alias QueryEngine.Query.Order

  import QueryEngine.Factory

  describe "build" do
    test "empty request" do
      person = insert(:person)

      response =
        %Request{schema: Dummy.Person}
        |> Builder.build
        |> Dummy.Repo.all
        |> Enum.map(&elem(&1, 0))

      id = person.id
      assert [%{id: ^id}] = response
    end

    test "preload request" do
      person = insert(:person)

      response =
        %Request{schema: Dummy.Person, side_loads: ["organization.country"]}
        |> Builder.build
        |> Dummy.Repo.all
        |> Enum.map(&elem(&1, 0))

      person_id = person.id
      organization_id = person.organization_id
      country_id = person.organization.country_id

      assert [%Dummy.Person{
        id: ^person_id,
        organization: %Dummy.Organization{
          id: ^organization_id,
          country: %Dummy.Country{id: ^country_id}
        }
      }] = response
    end

    test "filter request" do
      filter = %Filter{field: "email", operator: :=, value: "a"}

      person = insert(:person, email: "a")
      insert(:person, email: "b")

      response =
        %Request{schema: Dummy.Person, filters: [filter]}
        |> Builder.build
        |> Dummy.Repo.all
        |> Enum.map(&elem(&1, 0))

      person_id = person.id
      assert [%{id: ^person_id}] = response
    end

    test "join request" do
      person = insert(:person)
      insert(:person)

      filter = %Filter{field: "organization.name", operator: :=, value: person.organization.name}

      response =
        %Request{schema: Dummy.Person, filters: [filter]}
        |> Builder.build
        |> Dummy.Repo.all
        |> Enum.map(&elem(&1, 0))

      person_id = person.id
      assert [%{id: ^person_id}] = response
    end

    test "order request" do
      insert(:person, email: "b")
      insert(:person, email: "a")

      order = %Order{field: "email", direction: :asc}

      response =
        %Request{schema: Dummy.Person, sorts: [order]}
        |> Builder.build
        |> Dummy.Repo.all
        |> Enum.map(&(elem(&1, 0).email))

      assert ["a", "b"] == response

      # Test in reverse
      order = %Order{field: "email", direction: :desc}
      response =
        %Request{schema: Dummy.Person, sorts: [order]}
        |> Builder.build
        |> Dummy.Repo.all
        |> Enum.map(&elem(&1, 0))
        |> Enum.map(&(&1.email))

      assert ["b", "a"] == response
    end
  end
end
