# recipes

A recipe box and weekly meal planner for people who want help deciding what to
cook and what to buy. Keep your recipes in one place, scale them to the number of
people eating, drag them onto the days of the week and get a grocery list that adds
everything up, converts units and leaves out what is already in the cupboard.

It is a server-rendered Rails app: HTML from the server, Hotwire (Turbo and
Stimulus) for the interactive parts, PostgreSQL for storage.

## Features

- **Recipe box**: title, description, servings, prep and cook time, ingredients,
  method, tags, an optional photo and a link to where it came from.
  Ingredients are typed one per line (`200 g plain flour`, `1 onion, finely chopped`)
  and split into quantity, unit, name and note.
- **Scaling**: change the servings on a recipe and every amount is rescaled on the
  spot, with kitchen fractions for cups and spoons (`1 1/2 cups`) and decimals for
  metric amounts (`375 g`).
- **Import by pasting text**: paste a recipe from a website, an email or a note. The
  title, description, servings, prep and cook times, ingredients and steps are read
  out of it and shown in the normal recipe form to check before saving. Headings like
  _Ingredients_ and _Method_ help but aren't required.
- **Weekly meal planner**: a Monday-to-Sunday grid with breakfast, lunch, dinner and
  snack for each day. Drag recipes from the sidebar onto a slot, drag planned meals
  to move them, change the servings per meal, copy last week or clear the week.
  Every cell also has an _Add_ menu for touch screens and keyboards.
- **Grocery list**: built from the week's plan. Ingredients are scaled to the planned
  servings, matched by name (`Onions`, `large onion` and `onion` are one line) and
  added up across units: g and kg, ml and l, tsp, tbsp and cups.
  Sorted by aisle, with items you can tick off, extra items that aren't in any recipe,
  a print layout and a plain text version for pasting into a message.
- **Pantry**: what you already have. Staples without an amount (salt, olive oil)
  never go on the list; items with an amount (`1 kg flour`) are subtracted from it.
- **Favourites and search**: star recipes, search by title, description or
  ingredient, filter by tag or favourites and sort by newest, name or quickest.
- **Accounts**: sign up, sign in, password reset by email, change name, email and
  password, delete the account and everything in it.

## Stack

| Part      | Tech                                                                  |
| --------- | --------------------------------------------------------------------- |
| App       | Ruby 3.3, Rails 8.1, Hotwire (Turbo, Stimulus), importmap, Propshaft  |
| Auth      | Rails' built-in authentication (`has_secure_password`, DB sessions)  |
| Database  | PostgreSQL 17                                                         |
| Uploads   | Active Storage on local disk, resized with libvips                    |
| Tests     | Minitest (models, controllers, helpers), Node's test runner for JS    |
| Lint      | RuboCop (rails-omakase), Brakeman, bundler-audit                      |
| Ops       | Docker Compose, multi-stage Dockerfile, GitHub Actions                |

## Running with Docker

```bash
cp .env.example .env    # optional, the defaults work
docker compose up --build
```

Open <http://localhost:4402> and sign in as **demo@example.com** / **demo-password**.
The demo account has a dozen recipes, this week and last week planned, a pantry and
a grocery list with a couple of items ticked off. Set `SEED_DEMO=false` to start
empty.

| Service | Host port (env var)  | What                                        |
| ------- | -------------------- | ------------------------------------------- |
| `app`   | 4402 (`APP_PORT`)    | Rails; runs migrations and the seed on start |
| `db`    | 5442 (`DB_PORT`)     | PostgreSQL 17                                |

`GET /up` returns `{"status":"ok","database":"ok"}` when the app can reach the
database; the compose healthcheck uses it. Uploaded photos are kept in the `storage`
volume and the database in `db-data`; `docker compose down -v` removes both.

## Running without Docker

You need Ruby 3.3 and PostgreSQL. The quickest way to get the database is still
compose:

```bash
docker compose up -d db          # Postgres on localhost:5442, user/password "recipes"
bin/setup --skip-server          # installs gems, creates and migrates the databases
SEED_DEMO=true bin/rails db:seed # optional demo account
bin/dev                          # http://localhost:3000
```

To use your own Postgres, set `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`
and `DATABASE_PASSWORD` (see `config/database.yml`).

## Tests and lint

```bash
bin/rails test        # models, controllers and helpers (needs Postgres)
npm test              # JavaScript helpers, with Node 22's built-in test runner
bin/rubocop           # style
bin/brakeman          # security scan
bin/ci                # all of the above, the way CI runs them
```

There are no npm dependencies: the browser code is loaded through importmap and the
tests import the modules directly.

GitHub Actions (`.github/workflows/ci.yml`) runs RuboCop, Brakeman and the audits,
the Rails tests against Postgres, the JavaScript tests and a Docker build.

## License

MIT, see [LICENSE](LICENSE).
