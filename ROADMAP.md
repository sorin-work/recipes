# Roadmap

Things I might add to recipes. The app covers the loop from recipe to shop
today (recipe box, scaling, paste import, the weekly planner, the grocery
list, the pantry and cook mode), so nothing here is promised or scheduled.
These are ideas, written down with enough detail that I (or anyone else) can
pick one up later without starting from zero. Items may change, move between
groups or be dropped.

What the app does today is in the [README](README.md), including how
ingredients are read and added up.

- **Next**: small or well understood. I would start with these.
- **Later**: worth doing, but bigger or waiting on a decision.
- **Maybe**: not sure yet that they are worth the extra complexity.

Sizes are rough: **S** is an evening or two, **M** a few evenings up to a
couple of weekends, **L** several weeks of spare time.

Each item is meant to fit in one pull request and to be covered by the test
suite. There are no browser tests. `test/models` covers the plain Ruby objects
in `app/models` (`Unit`, `Quantity`, `IngredientParser`, `Amount`,
`GroceryList`, `RecipeImport` and the rest) and the Active Record models,
`test/controllers` runs requests against PostgreSQL with `sign_in_as` from
`test/test_helpers/session_test_helper.rb`, and `test/javascript` runs the
modules in `app/javascript/lib` with Node's test runner. So logic worth testing
(parsing, conversions, matching, dates) belongs in a plain object under
`app/models` or a module under `app/javascript/lib`, not inside a controller,
a view or a Stimulus controller. Items that change the database bring a
migration under `db/migrate` and the updated `db/schema.rb`.

When an item ships, its Overview cell says `Shipped`, its section moves under
a `## Shipped` heading at the end and shrinks to one paragraph on what was
built and where, and the same pull request updates the README and adds a line
to the `Unreleased` section of `CHANGELOG.md` (the first item to ship creates
that file).

"Depends on" lists real prerequisites only. Items that merely touch the same
file are not listed there; the bigger overlaps are mentioned in the items.

## Overview

| #   | Item                                         | Group | Area        | Size | Depends on |
| --- | -------------------------------------------- | ----- | ----------- | ---- | ---------- |
| 1   | Confirming a new email address               | Next  | accounts    | S    | -          |
| 2   | Exporting the recipe box                     | Next  | data        | S    | -          |
| 3   | Deleting a recipe without losing past weeks  | Next  | recipes     | S    | -          |
| 4   | Photo links that need a sign in              | Next  | security    | M    | -          |
| 5   | Background jobs that survive a restart       | Next  | ops         | S    | -          |
| 6   | Backups and restore                          | Later | ops         | M    | -          |
| 7   | Importing from a web address                 | Later | import      | M    | -          |
| 8   | Importing from other recipe apps             | Later | import      | M    | -          |
| 9   | Signed-in devices                            | Later | accounts    | S    | -          |
| 10  | Sharing with the people you live with        | Later | sharing     | L    | -          |
| 11  | A public link to one recipe                  | Later | sharing     | S    | 4          |
| 12  | "Cooked it": history and ratings             | Later | recipes     | M    | -          |
| 13  | Notes and meals out in the planner           | Later | planner     | S    | -          |
| 14  | Leftovers                                    | Later | planner     | M    | -          |
| 15  | Shopping for any run of days                 | Later | groceries   | M    | -          |
| 16  | Fixing grocery lines                         | Later | groceries   | M    | -          |
| 17  | Your own aisles                              | Later | groceries   | S    | -          |
| 18  | Cups to grams for common ingredients         | Later | units       | M    | -          |
| 19  | Metric or US measures                        | Later | units       | S    | -          |
| 20  | A pantry that follows what you cook          | Later | pantry      | M    | 12         |
| 21  | What can I make with what I have             | Later | recipes     | M    | -          |
| 22  | Timers in cook mode                          | Later | cook        | S    | -          |
| 23  | Amounts in the method that scale             | Later | cook        | M    | -          |
| 24  | Suggestions for the week                     | Later | planner     | M    | 12         |
| 25  | Time zone and first day of the week per person | Later | settings  | S    | -          |
| 26  | Accessibility pass                           | Later | ui          | M    | -          |
| 27  | Closing sign-ups on a private instance       | Later | ops         | S    | -          |
| 28  | Large recipe boxes                           | Later | performance | M    | -          |
| 29  | Edit history of a recipe                     | Maybe | recipes     | M    | -          |
| 30  | A small API with tokens                      | Maybe | api         | M    | -          |
| 31  | Nutrition estimates                          | Maybe | recipes     | L    | 18         |
| 32  | The grocery list offline                     | Maybe | groceries   | L    | -          |
| 33  | Translations                                 | Maybe | ui          | L    | -          |
| 34  | Printing a cookbook                          | Maybe | recipes     | M    | -          |
| 35  | Two-step sign in                             | Maybe | accounts    | M    | -          |
| 36  | More than one photo                          | Maybe | recipes     | M    | 4          |

## Next

### 1. Confirming a new email address

`AccountsController#update` changes `email_address` with nothing but the
signed-in session: no current password, no confirmation mail to either
address. Password changes ask for the current password and account deletion
asks for it too, so this is the odd one out, and it is the dangerous one.
Someone with a few minutes at an unlocked laptop can change the address to
their own, then use "forgot password" (`PasswordsController#create`) and own
the account.

- Ask for the current password when the email changes, like
  `PasswordChangesController#update` does with `authenticate`.
- Do not switch the address at once. Store it in `unconfirmed_email` on
  `users`, mail a link to the new address, and switch when it is opened. The
  link can be a signed, expiring token from `generates_token_for
  :email_change` keyed on the pending address, the same mechanism
  `has_secure_password` uses for the password reset token, so no table is
  needed.
- Mail the old address as well: "Your email address is being changed to ...;
  if this was not you, change your password". The mailer sits next to
  `PasswordsMailer` with text and HTML templates.
- After the switch, sign out other sessions as a password change does.
- Tricky: uniqueness. Two accounts may ask for the same new address; the one
  who confirms first wins and the second link fails with a clear message,
  checked again when the link is used, not only when it was requested.
- Tricky: without `SMTP_ADDRESS` mails go to `tmp/mails` (the production
  config's `:file` delivery). On such an instance nobody could ever change
  their address. Show the pending address on the Account page with a "cancel"
  button, and say in the README that changing the address needs mail.
- Tests: controller tests in `test/controllers/accounts_controller_test.rb`:
  wrong password refused, address unchanged until the link is used, both mails
  sent (`assert_emails`), an expired or reused link, the address taken in the
  meantime, other sessions signed out.

### 2. Exporting the recipe box

There is no way to get recipes out of the app except printing them one by
one. Deleting the account deletes everything, and a broken server takes years
of recipes with it. An export is also the first half of moving between
instances and the base for item 8.

- `GET /account/export` returns a zip with `recipes.json` and a `photos/`
  folder. Each recipe has its title, description, servings, times, source,
  notes, tags, favourite flag, ingredients as the original lines
  (`Ingredient#to_line`) plus the parsed parts, steps, and the photo's file
  name. The meal plan, pantry and grocery extras go in as well.
- Also offer each recipe on its own as schema.org `Recipe` JSON-LD, which many
  other apps can import, from a link on the recipe page.
- A matching import of the app's own zip on the Account page, which adds the
  recipes to the current account (never replaces) and renames clashing tags
  onto existing ones as `TagsController#update` does when merging.
- Build the JSON in a plain `RecipeBoxExport` object so it can be tested without
  a request; the import reuses `ingredients_text=` and `steps_text=` from
  `Recipe` so parsing stays in one place.
- Tricky: photos. Streaming the zip avoids holding a few hundred photos in
  memory; `zip_kit` streams from a Rails controller, or `rubyzip` writes to a
  tempfile first, which is simpler and fine for a personal box.
- Tricky: the importer must treat the file as untrusted: limits on the number
  of recipes, the length of every field (the model validations already apply),
  photo types and sizes (`Recipe::PHOTO_TYPES`, `PHOTO_MAX_SIZE`), and zip
  paths that try to leave the folder.
- Tests: model tests for the export shape and a round trip (export, import into
  another user, compare); controller tests for the download needing a sign in
  and for a malformed or oversized file.

### 3. Deleting a recipe without losing past weeks

`Recipe` has `has_many :meal_plan_entries, dependent: :delete_all`. Deleting a
recipe quietly removes it from every week it was ever planned in, so last
month's plan gets holes, "Copy last week" copies less than was eaten, and a
grocery list for a past week changes. There is also no way back from a delete:
the confirmation is the only safety.

- Soft delete: an `archived_at` on `recipes`. "Delete" archives; archived
  recipes leave the recipe list, search, the planner sidebar and the dashboard,
  but past plan entries keep pointing at them and show the title with
  "(deleted)".
- A "Deleted recipes" page with "Restore" and "Delete for good". Deleting for
  good is the old behaviour, with the plan entries named in the confirmation.
- Plan entries for days after today that point at an archived recipe are
  removed when it is archived, because nobody wants to cook a deleted recipe
  next Tuesday.
- Tricky: every place that lists recipes needs the scope: `RecipesController`,
  `PlansController#show` (`@recipes`), `DashboardController`, the tag counts
  in `TagsController`, and `MealPlanEntry#recipe_belongs_to_user` should refuse
  archived ones. A default scope would hide them from the past plans too, which
  is the opposite of the point, so use an explicit `kept` scope.
- Tricky: `GroceryList#build_items` for a past week should still include an
  archived recipe's ingredients, so the old list reads as it did.
- Undecided: clean up archived recipes automatically after some months. I lean
  towards no: they take little space and the page makes them easy to purge.
- Tests: model tests for the scopes; controller tests for archive, restore,
  delete for good, future entries removed and past ones kept.

### 4. Photo links that need a sign in

Recipe photos are shown with `image_tag recipe.photo.variant(...)`, which in
Rails means a redirect URL under `/rails/active_storage/representations/...`.
Those URLs carry a signed blob id that never expires, and Active Storage's
controllers do not run the app's authentication. Anyone with the link (a
shared screenshot, a browser history, a proxy log) can load the photo forever,
even after signing out or deleting the account until the blob is purged. For a
private recipe box that is a surprise, and for photos of a kitchen at home it
can be more than a surprise.

- Serve photos through the app's own controller: `GET
  /recipes/:id/photo/:variant` looks up the recipe through `Current.user`, then
  sends the variant with `send_data` or streams it from the service, with a
  private cache header.
- Turn off the public Active Storage routes (`config.active_storage.draw_routes
  = false`) so the old URLs stop working, and draw only what the app needs.
- Views use a helper (`recipe_photo_tag(recipe, :card)`) instead of
  `image_tag recipe.photo.variant`.
- Strip metadata from what is served. libvips variants drop most EXIF data
  when saving, but the original is never served after this change anyway; a
  `:large` variant becomes the largest image anyone sees.
- Tricky: direct uploads and the form preview. The recipe form uploads with the
  form, not by direct upload, so nothing else needs the Active Storage
  routes; check `_form.html.erb` and the import page.
- Tricky: performance. Proxying through Rails costs a Puma thread per image.
  Variants are small (640 by 420 for cards), the recipe list is paged at 24,
  and a long `Cache-Control: private, max-age` lets the browser keep them.
- Tests: controller tests that a photo needs a sign in, that another user gets
  404, and that the Active Storage route is gone.

### 5. Background jobs that survive a restart

Password reset mails go out with `deliver_later`, `RecipesController#update`
removes photos with `purge_later`, and Active Storage analyses uploads in a job
too. No queue adapter is configured, so production uses Rails' `:async`
adapter: jobs run in a thread inside Puma and are gone if the container
restarts or is redeployed in the meantime. A lost reset mail is the user's
problem to notice; a lost purge leaves the file on disk forever.

- Solid Queue on the existing PostgreSQL, run inside Puma with the
  `solid_queue` Puma plugin (`SOLID_QUEUE_IN_PUMA`), so the compose file keeps
  one app service and no Redis. It is the Rails 8 default and needs its tables
  (`bin/rails solid_queue:install`, migrations or a second schema).
- `config.active_job.queue_adapter = :solid_queue` in production; tests keep
  the test adapter.
- Mission Control is overkill here; a line in the health check
  (`HealthController`) with the number of failed jobs, and a
  `bin/rails jobs:failed` task, are enough to notice trouble.
- Tricky: Solid Queue's tables in the same database are simplest. Its
  recommended setup is a separate database; for one person's recipes the same
  database is fine and keeps `docker compose` and the backup (item 6) simple.
- Tricky: `db:prepare` in `bin/docker-entrypoint` must create the queue tables
  on existing volumes too, which is what migrations in the main schema give.
- Tests: an integration test that a password reset enqueues the mail job; the
  adapter itself is Rails' to test. The demo seed step in CI proves the tables
  exist after `db:prepare`.

## Later

### 6. Backups and restore

Recipes live in the `db-data` volume and photos in `storage`, and the README
only says that `docker compose down -v` removes both. There is no backup
command and no restore story. For many people this is the one copy of the
family recipes.

- A `backup` service in `docker-compose.yml` behind a compose profile, so it
  only runs when asked: once a night `pg_dump -Fc` of the database plus a tar of
  `storage`, written to a bind-mounted folder, keeping the last N
  (`BACKUP_KEEP`, default 14).
- `bin/restore <folder>` or a documented sequence: stop `app`, `pg_restore
  --clean`, unpack `storage`, start `app`. `db:prepare` on start migrates an
  older dump forward.
- A short operations section in the README: backup, restore, upgrading
  (`docker compose pull` or rebuild, the entrypoint migrates), and where logs
  go.
- Tricky: dump first, then copy files. A photo uploaded in between is a file
  without a row, which is harmless; the other order gives rows without files.
- Tricky: the export from item 2 is not a backup. It is per user and leaves out
  sessions and accounts; the backup is the whole instance.
- Tests: CI can restore a dump of the demo seed into a fresh database in the
  `test` job and boot the app against it. The scripts themselves are checked
  with `bash -n`.

### 7. Importing from a web address

Pasting text works (`RecipeImport`) but copying a recipe page cleanly is
fiddly on a phone, and almost every recipe site publishes the recipe as
schema.org `Recipe` JSON-LD for search engines. Reading that is more reliable
than any text heuristic.

- A "From a web address" tab on the import page. The server fetches the page,
  finds `<script type="application/ld+json">` blocks, picks the `Recipe`
  (also inside `@graph`), and maps `name`, `description`, `recipeYield`,
  `prepTime` and `cookTime` (ISO 8601 durations, which `DurationParser`
  already reads), `recipeIngredient`, `recipeInstructions` (strings,
  `HowToStep` or `HowToSection`, the last becoming groups) and `keywords`.
- The result fills the normal recipe form as the paste import does, with
  `source_url` set. If there is no JSON-LD, fall back to the page's text
  through `RecipeImport`.
- Optionally fetch the image named in the JSON-LD and attach it, after the
  same type and size checks as an upload.
- A plain `RecipeSchemaReader` that takes HTML and returns attributes, so most
  tests need no network.
- Tricky: fetching URLs from the server is a way to reach things the server can
  see and the user cannot (SSRF): `localhost`, the database container,
  `169.254.169.254`. Resolve the host first and refuse private, loopback and
  link-local addresses, follow at most a few redirects and check each one, and
  cap the size and the time.
- Tricky: sites that block non-browser clients or need JavaScript. Say "this
  site did not let us read the recipe, paste the text instead" rather than
  pretending.
- Tricky: duplicates. Importing the same address twice is common; if a recipe
  with that `source_url` exists, offer to open it.
- Tests: unit tests for `RecipeSchemaReader` with saved pages (plain, `@graph`,
  sections, missing fields); a controller test with the HTTP call stubbed; tests
  for the address checks (private ranges, redirect to a private address).

### 8. Importing from other recipe apps

People arrive with recipes in another app. Paprika, Mealie, Tandoor,
Nextcloud Cookbook and others export to files, and several of them use
schema.org JSON or a simple variant of it.

- An import page that takes a file and detects the format: a Paprika
  `.paprikarecipes` archive (a zip of gzipped JSON files), a zip or JSON array
  of schema.org recipes (which covers Nextcloud Cookbook and Mealie exports),
  and this app's own export from item 2.
- Every format maps to the same attributes and goes through `Recipe` with
  `ingredients_text` and `steps_text`, so the parser and its limits apply.
- A preview with the number of recipes, duplicates by title or source, and
  skipped entries, before anything is saved; then one transaction.
- Tricky: format drift. These exports are not documented as stable; keep one
  small reader per format and real sample files in `test/fixtures/files`.
- Tricky: ingredient lines from other apps are often already split into amount
  and name; join them back into a line before parsing so the parser decides.
- Tests: one model test per reader with a fixture file, and a controller test
  for preview and import.

### 9. Signed-in devices

Sessions are rows in `sessions` with the IP address and user agent, the cookie
is `permanent` (20 years), and nothing ever expires them. There is no list of
where I am signed in and no "sign out everywhere" short of changing the
password.

- A "Signed in on" list on the Account page: device (from the user agent),
  IP, first seen and last seen, with "sign out" per row and "sign out all
  other devices".
- `last_seen_at` on sessions, updated at most every few minutes in
  `resume_session` so it is not a write per request.
- Expire sessions not seen for 90 days: a check in `find_session_by_cookie`,
  and a cleanup that deletes old rows (a recurring Solid Queue task if item 5
  has landed, otherwise a rake task).
- Tricky: the cookie lives 20 years while the row dies after 90 days of
  silence; a request with a cookie for a deleted session simply goes to the
  sign in page, which is the existing behaviour.
- Tests: controller tests for the list, signing out one other session, and an
  expired session being refused.

### 10. Sharing with the people you live with

Everything belongs to one user (`Current.user` scopes every query, as the
README says). A couple who cook together need two accounts with two recipe
boxes and two grocery lists, or share one password. Shared plans and lists are
the most common request for apps like this.

- A `Household` with members. Recipes, tags, the plan, grocery checks and
  extras, and the pantry move from `user_id` to `household_id`; every account
  starts with a household of one, so nothing changes for single users.
- Invite by link (signed, expiring, single use) or by email once mail is
  reliable. Every member can do everything; roles can wait.
- Live updates on the grocery list while two people shop: the list already
  uses Turbo's morphing refresh, and `broadcasts_refreshes` on the checks and
  extras would push a refresh to the other phone over Action Cable. That needs
  Solid Cable (or the async adapter for one Puma process) and a cable
  connection that authenticates with the session cookie
  (`app/channels/application_cable/connection.rb` exists but is empty).
- Tricky: the migration. Every table, every scope and every `belongs_to
  :user` changes, and `Current.user.recipes` is written all over the
  controllers. Add `Current.household` first, switch the controllers to it in
  one commit with no behaviour change, then move the columns.
- Tricky: leaving. Someone who leaves takes nothing by default; offer to copy
  their own recipes (by a `created_by` column) into a new household.
- Tricky: two people editing the same recipe. The last save wins today; with a
  household it happens. `lock_version` on recipes gives a clear "someone else
  changed this" instead of a silent overwrite.
- Tests: model tests for the migration of data; controller tests that a member
  sees the shared plan and list, that a non-member gets 404 everywhere, and for
  invitations and leaving.

### 11. A public link to one recipe

Sending a recipe to a friend means copying text or a screenshot. A read-only
link to one recipe, without an account, is the usual answer.

- A "Share" button on the recipe page creates a random token
  (`share_token`, nullable and unique on `recipes`), shown as a link, with
  "stop sharing" to clear it.
- `GET /r/:token` shows the recipe with scaling and the print layout, no
  navigation and no edit buttons, and a `noindex` header.
- The photo on the shared page goes through the controller from item 4, which
  allows it when the token matches.
- Tricky: the page must not leak anything else: no notes field (private
  notes are part of the recipe today, so the share page leaves `notes` out),
  no tags, no planner links.
- Depends on item 4, because the photo access rule lives there.
- Tests: controller tests for a shared recipe without a sign in, a cleared
  token returning 404, notes not shown, and the photo through the token.

### 12. "Cooked it": history and ratings

The app knows what was planned (`Recipe#last_planned_on`) but not what was
cooked, how it went or what I would change. People keep these notes in the
margins of cookbooks.

- A "Cooked it" button on the recipe page and in cook mode at the last step,
  that logs a `Cooking` (recipe, date, servings, an optional 1 to 5 rating and
  a note: "less salt next time").
- The recipe page shows the history and the average rating; the list can sort
  by rating and "not cooked for a while".
- A planned meal in the past can be confirmed as cooked from the planner with
  one click, which is the cheapest way to fill the history.
- Tricky: planned is not cooked. Do not log plan entries automatically; the
  planner shows "Cooked?" on past entries instead.
- Tricky: the rating belongs to a cooking, not the recipe, so the recipe's
  rating is an average or the latest. I lean towards the latest, which follows
  the recipe as it is edited.
- Tests: model tests for the averages and sorting; controller tests for logging
  from the recipe page and from the planner.

### 13. Notes and meals out in the planner

Every planner slot must hold a recipe (`MealPlanEntry belongs_to :recipe`).
"Pizza out", "at Mum's", "leftovers" or "something from the freezer" cannot be
planned, so the week looks emptier than it is and copying last week leaves
gaps.

- Plan entries with a short text instead of a recipe: `recipe_id` becomes
  nullable, with a `label` column, and exactly one of the two is set.
- The cell's _Add_ menu (`plans/_cell.html.erb`) gets "Add a note". Notes can
  be dragged like meals.
- Notes add nothing to the grocery list; `GroceryList#entries` skips them.
- Tricky: `MealPlanEntry` code assumes a recipe: `scale`, the
  `before_validation` that copies servings, the cell partial, the turbo stream
  notices ("Added #{@entry.recipe.title}"). Each needs the no-recipe case.
- Tests: model tests for the validation; controller tests for adding, moving and
  copying a note, and the grocery list ignoring it.

### 14. Leftovers

Cooking for four and eating for two is the normal case, and the planner treats
the other two portions as gone. People plan "cook once, eat twice" on paper.

- When a planned meal has more servings than people eating, offer "Plan the
  rest as leftovers for ..." with a day and meal. The leftover entry points at
  the same recipe and is marked `leftover_of_id`.
- Leftover entries add nothing to the grocery list: the shopping is done for
  the first entry, which keeps its full servings.
- Moving or deleting the original asks about its leftovers.
- Tricky: the grocery list scales by `servings` per entry
  (`MealPlanEntry#scale`), so the original must carry the total and the leftover
  must count zero. A `leftover_of_id` with the leftover skipped in
  `GroceryList#entries` keeps that simple.
- Tricky: leftovers across a week boundary. Cooking on Sunday and eating on
  Monday puts the leftover in the next week, whose grocery list must still skip
  it.
- Tests: model tests for the grocery list with leftovers inside and across
  weeks; controller tests for creating and moving them.

### 15. Shopping for any run of days

The grocery list is built for one Monday-to-Sunday `Week`, and the checks and
extras are keyed by `week_start`. Many people shop on Saturday for Saturday to
Friday, twice a week, or for ten days.

- A grocery list for a date range: from a chosen day for a number of days,
  defaulting to this week as today. `GroceryList` takes a range instead of a
  `Week`; `Week` keeps its job on the planner.
- Saved shopping trips: a `ShoppingTrip` with its dates, so checks and extras
  belong to a trip instead of a week. The migration turns each week with checks
  into a trip.
- "Shop for the rest of the week" starting today is the shortcut most people
  want.
- Tricky: overlapping trips. If Wednesday's dinner was already on Saturday's
  list, a Tuesday trip for Tuesday to Thursday buys it again. Mark days that are
  covered by an earlier trip and leave them out unless asked.
- Tricky: grocery checks are keyed by item key per week; a check stays when the
  amount grows because another recipe was added. Within a trip that should
  untick the item and say why ("+200 g since you ticked it").
- Tests: model tests for ranges, overlaps and the migration of checks;
  controller tests for the trip pages.

### 16. Fixing grocery lines

Matching by `IngredientName.key` is good but not perfect, and when it is wrong
there is nothing to do about it on the list. "Spring onion" and "scallion" are
two lines; "chicken thighs" and "chicken breast" are two lines (correct), but
"cherry tomatoes" and "tomatoes" are two lines when I would buy one bag; and an
amount cannot be changed ("I will buy the 1 kg pack").

- Merge two lines on the list into one, and remember it as an alias per user
  (`IngredientAlias`: from key, to key), applied in `GroceryList#build_items`
  next to `IngredientName.key`. The pantry uses the same aliases.
- Split a merged line back, which removes the alias.
- Override the amount or the text of a line for this list, stored like checks.
- A small "Ingredient names" page lists the aliases, to undo old merges.
- Tricky: aliases chain (a to b, b to c). Resolve them once when loading, and
  refuse a merge that would make a loop.
- Tricky: the item key is also the key of the grocery check. After a merge the
  check of the old line should carry over to the new one, or ticked items
  reappear.
- Tests: model tests for `GroceryList` with aliases, chains and checks carried
  over; controller tests for merge, split and overrides.

### 17. Your own aisles

`Aisle` sorts the list by keyword into seven sections in a fixed order. Every
shop is laid out differently, the keywords are English and British-leaning,
and when an item lands in "other" it stays there.

- Move an item to another section from the list, remembered per user by
  ingredient key (`AisleChoice`), and used before the keyword rules in
  `Aisle.for`.
- Reorder the sections to match the shop, and rename them; stored as a list on
  the user.
- Tricky: `Aisle.for` is a module function without a user today, called from
  `GroceryList::Item#initialize`. Pass the user's choices into `GroceryList`
  and give `Item` its aisle from there.
- Undecided: several shops with different orders. Useful for the market plus
  the supermarket, but I would wait for someone to ask.
- Tests: model tests for choices winning over keywords and for the custom
  order; a controller test for moving an item.

### 18. Cups to grams for common ingredients

Amounts add up within mass or within volume (`Amount` keeps grams and
millilitres), but one recipe saying `1 cup flour` and another `200 g flour`
gives `1 cup + 200 g` on the list, and a pantry with `1 kg flour` cannot
subtract a cup. This is the most visible limit of the unit handling.

- A density table for common baking and cooking ingredients (flour, sugar,
  brown sugar, icing sugar, butter, rice, oats, milk, honey, grated cheese and
  so on) in grams per millilitre, as data in a Ruby file or YAML, keyed by
  `IngredientName.key`.
- `Amount` learns to convert volume to mass when the ingredient has a density,
  and the grocery list adds them up in grams.
- Show the conversion as approximate: "about 320 g".
- Tricky: density depends on the ingredient more than people expect (a cup of
  sifted flour is lighter than a cup of packed flour). Keep the table short and
  well known; leave out anything that varies a lot.
- Tricky: the key must match exactly. "Self-raising flour" and "plain flour"
  differ a little; "flour" alone should use plain flour's density.
- Tests: model tests for `Amount` with densities, a list that combines `1 cup
  flour` and `200 g flour`, and the pantry subtracting a cup from a kilo.

### 19. Metric or US measures

Recipes keep the units they were written in, and `Quantity.format` chooses
fractions or decimals by unit. Someone with a metric kitchen reading an American
recipe converts ounces and Fahrenheit in their head; the reverse is true for US
cooks reading British recipes.

- A preference on the Account page: as written, metric, or US customary.
- Conversion at display time only, on the recipe page, in cook mode and on the
  grocery list. Stored ingredients never change. Volumes stay volumes unless a
  density exists (item 18), so `1 cup` becomes `240 ml`, not grams, without it.
- Oven temperatures in steps (`180°C`, `350°F`, `gas mark 4`) converted with a
  small pattern, shown next to the original.
- The JavaScript rescaling (`app/javascript/lib/quantities.js`) has to apply the
  same conversion, because the servings control rescales in the browser.
- Tricky: rounding. 1 cup is 236.6 ml; showing `236.6 ml` is silly and `250
  ml` is wrong for baking. Round to kitchen-friendly steps and keep the
  original on hover or in brackets.
- Tests: Ruby model tests and matching JavaScript tests for the conversions, so
  both sides agree.

### 20. A pantry that follows what you cook

Pantry items with an amount are subtracted from the list, but nothing
subtracts them from the pantry after cooking. A kilo of flour stays a kilo
forever, so the pantry is only right on the day it was typed in.

- When a meal is marked cooked (item 12), offer to take its ingredients off the
  pantry, scaled to the servings, using the same `Amount` arithmetic as the
  grocery list.
- When grocery items are ticked as bought, offer to add them to the pantry.
- Optional "use by" dates on pantry items, and a short list on the dashboard of
  what to use up soon.
- Tricky: the user never measures exactly, so the pantry drifts anyway. Never
  let an amount go below zero, and show "running low" rather than precise
  numbers when it gets close.
- Depends on item 12 for the "cooked" event.
- Tests: model tests for subtracting with unit conversion and floors at zero;
  controller tests for the offers.

### 21. What can I make with what I have

The pantry is used only to shorten the grocery list. The question it could
answer is "what can I cook tonight without shopping?"

- A filter on the recipe list: "Uses what I have", ordering recipes by the
  share of their ingredients (not counting headings and staples) found in the
  pantry, and showing what is missing ("missing: 2 eggs, cream").
- Matching by `IngredientName.key` and the aliases from item 16 if they exist.
- Tricky: amounts. A recipe needing 500 g of rice when the pantry has 100 g is
  not makeable; compare amounts where both sides have them and treat
  amount-less pantry items as enough.
- Tricky: performance. Doing it in Ruby for every recipe on every request is
  fine for a few hundred recipes; beyond that, item 28.
- Tests: model tests for the ranking with staples, amounts and headings.

### 22. Timers in cook mode

Cook mode shows one step at a time, keeps the screen awake and moves with the
arrow keys. Steps say "simmer for 20 minutes" and the cook reaches for a phone
timer with flour on their hands.

- Durations in step text become buttons: "20 minutes" starts a countdown on
  the page. Parsing in a JavaScript module next to `lib/steps.js`, with the same
  rules as `DurationParser` (and tests that keep them in sync).
- Several timers can run at once, each labelled with its step; a sound and a
  vibration (where supported) when one ends.
- Tricky: the page may be in the background. Timers must use the end time, not
  count ticks, so a throttled tab still rings on time when it comes back, and
  the title shows the remaining time.
- Tricky: ranges ("25 to 30 minutes") start the shorter one with a note.
- Tests: JavaScript tests for finding durations in text and for the remaining
  time calculation.

### 23. Amounts in the method that scale

Scaling changes the ingredient list but not the steps. "Add the 200 g of
flour" still says 200 g when the recipe is doubled, and in cook mode the steps
are what people read.

- Find quantities with units in step text (`200 g`, `2 tbsp`, `1 1/2 cups`)
  with `Quantity.scan` and `Unit`, and scale them with the same factor, on the
  server for the recipe page and in `lib/quantities.js` for the live servings
  control.
- Only scale amounts that match an ingredient line's unit and are not times or
  temperatures: "bake for 20 minutes at 180°C" must not become 40 minutes at
  360°C.
- Show scaled amounts highlighted, so the cook knows the text was changed.
- Tricky: false positives ("a 23 cm tin", "2 eggs" when eggs are counted, "1
  hour"). Keep a list of units that are never scaled in steps (lengths,
  temperatures, time) and test with the demo recipes.
- Undecided: scale counted amounts ("2 eggs"). Usually right, sometimes not
  ("2 tablespoons of the mixture"); I lean towards scaling only when the counted
  thing matches an ingredient name.
- Tests: Ruby and JavaScript tests over real step texts.

### 24. Suggestions for the week

Planning is the part people find hardest: deciding what to cook. The planner
gives a sidebar of all recipes sorted by favourite and title, and "copy last
week".

- A "Suggest" button per empty slot, and "Fill the empty dinners", that picks
  from the recipe box with simple rules: favourites and high ratings more often,
  nothing cooked in the last two weeks, a mix of tags, quick recipes on chosen
  weekdays.
- Suggestions are shown in the slot to accept or reroll, not saved until
  accepted.
- The picking is a plain `MealSuggester` that takes recipes, history and rules
  and a random generator, so tests can fix the randomness.
- Depends on item 12 for "last cooked" and ratings; with only planning history
  it works but is weaker.
- Tricky: small recipe boxes. With twelve recipes the rules exclude everything;
  relax them in order and say which was relaxed.
- Tests: model tests for the rules and the relaxing with a seeded random.

### 25. Time zone and first day of the week per person

`TIME_ZONE` is one setting for the whole instance (it decides "today" on the
planner and the dashboard), and weeks always start on Monday
(`beginning_of_week(:monday)` in `Week`). A shared instance with a friend
abroad shows them the wrong today, and many people plan Sunday to Saturday.

- `time_zone` and `week_starts_on` on users, set from the browser's time zone
  at sign up and changeable on the Account page.
- An `around_action` in `ApplicationController` that runs each request in the
  user's zone with `Time.use_zone`; `Date.current` then follows.
- `Week` takes the first day; `?week=` parameters stay ISO dates of the first
  day.
- Tricky: existing checks and extras are keyed by a Monday `week_start`. A user
  who switches to Sunday weeks would lose this week's ticks; migrate the keys
  of the current and future weeks or keep Monday keys internally and only shift
  the display. I lean towards the second, which item 15 replaces anyway.
- Tests: model tests for `Week` with a Sunday start; controller tests that
  today follows the user's zone.

### 26. Accessibility pass

A lot is in place: headings, `aria-labelledby` on sections, visually hidden
labels, an _Add_ menu as the alternative to drag and drop, keyboard steps in
cook mode. Gaps to check:

- The planner's drag and drop has no live announcement; moving with the menu
  works, but after a Turbo stream replaces a cell, focus is lost.
- Week navigation uses arrow characters with `aria-label`, which is fine, but
  the current week label should be the page's heading or announced on change.
- The grocery list ticks items with auto-submitting forms; after the morphing
  refresh the focus should stay on the checkbox that was ticked.
- Cook mode's highlighted step needs `aria-current="step"`, and the status line
  a live region.
- Colour contrast of muted text and quiet buttons in both colour schemes.
- Approach: a pass with axe and a screen reader per page, fixes, and a short
  checklist in the README for new views.
- Tricky: no browser tests, so most of this is checked by hand. Controller tests
  can assert attributes in the rendered HTML (`assert_select`), which catches
  regressions in markup.
- Tests: `assert_select` checks for the attributes added.

### 27. Closing sign-ups on a private instance

`/registration/new` is open to anyone who can reach the app. Most people run
this for one household; an open sign-up page on a public address invites
accounts nobody wanted, and with password reset each of them can make the
server send mail.

- `REGISTRATION=open|closed` (default open, as today). Closed hides the link
  on the sign in page and answers 404 on the registration routes.
- A `bin/rails users:create` task for adding accounts when sign-ups are closed,
  which also covers the first account.
- Tests: controller tests for both modes and a test for the task.

### 28. Large recipe boxes

The app is built for a few hundred recipes and is quick at that size. Some
people import thousands (item 8 makes that easy), and a few places would slow
down:

- The planner sidebar (`PlansController#show`) loads every recipe on every
  visit to the planner, filtered in the browser by `filter_controller.js`.
- `Recipe.search` matches `description` with `ILIKE` and has trigram indexes on
  `recipes.title` and `ingredients.name` only.
- The tag list (`Current.user.tags.where(id: Tagging.select(:tag_id))`) scans
  all taggings, not only the user's.
- `RecipesController#index` counts the whole filtered scope for paging on every
  request.
- Approach: a test fixture with a few thousand recipes built with `insert_all`,
  assertions on query counts and on `EXPLAIN` using the indexes, not on time.
  Then a server-side search for the planner sidebar (the filter already
  debounces input), a trigram index for descriptions if search needs it, and a
  scoped tag query.
- Tricky: the sidebar is also the drag source. A server-side filter that
  replaces the list must keep the drag data (`lib/drag_data.js`) working.
- Undecided: full text search with `tsvector` instead of trigrams. Better
  ranking, but language-specific stemming; trigrams are fine for titles and
  ingredient names.
- Tests: query count tests and an `EXPLAIN` check in the controller tests.
