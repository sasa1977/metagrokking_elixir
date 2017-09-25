# Installation

This project has the following prerequisites:

- PostgreSQL 9.4 or higher
- Erlang, Elixir, and Node.js (versions are listed [here](./.tool-versions)).

  You can optionally use [asdf](https://github.com/asdf-vm/asdf) to install Erlang, Elixir, and Node.js. Simply install `asdf` and required plug-ins, and run `asdf install` from the root folder of this project.

With all prerequisites met, here are the steps to setup the project:

Make sure the PostgreSQL server is running on port 5432, and create the database user:

```sql
create user shopping_list with createdb password 'shopping_list';
```

Create dev and test databases and migrate them:

```
mix do ecto.create, ecto.migrate
MIX_ENV=test mix do ecto.create, ecto.migrate
```

Install npm packages and build assets:

```
cd assets
npm install
node node_modules/brunch/bin/brunch build
cd ..
```

Start the server:

```
iex -S mix phx.server
```
