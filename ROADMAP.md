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
