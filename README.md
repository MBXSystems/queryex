# QueryEx

A SQL query engine framework for building APIs in Elixir.  Allows generating an
Ecto query using dynamic query parameters.


## Example

```
MyModels.User
  |> QueryEx.from_schema
  |> QueryEx.side_load("organization.country")
  |> QueryEx.filter("name", :like, "John D%")
  |> QueryEx.filter("organization.name", :=, "Test Organization")
  |> QueryEx.order_by("inserted_at", :desc)
  |> QueryEx.page(10, 20)
  |> QueryEx.build
  |> MyApp.Repo.all
```

## Why?

We use this system internally for creating our API.  We needed something 
dynamic, but still powerful enough to handle side loading, joining, and
traditional SQL filtering.

With this system, we're able to spin up new endpoints in minutes without
having to worry about how the data is managed.

## What it's not

`QueryEx` is not a public facing API interface.  You should build your
API on top of this instead.  While the framework does return a client readable
format, similar to [JSON API](http://jsonapi.org/), we don't handle the serializing.  We also do not
have the web client API defined here.

This framework does not handle security.  You may include a base query to
filter off of instead of the raw schema.  This allows you to include a basic
filter to filter out results before going through the framework.

## Contributing

### Requirements

You will need the following to build this project

* Elixir v1.6+
* Docker and Docker Compose

We included a `docker-compose.yml` file that will start up a Postgres database that
can be used by the unit tests.

### Building

```
$ docker-compose start
Starting db ... done

$ mix test
.......................................................................................

Finished in 0.9 seconds
9 doctests, 78 tests, 0 failures
```

### Stopping Docker

```
$ docker-compose stop
Stopping query_ex_db_1 ... done
```
