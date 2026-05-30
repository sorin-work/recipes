import { test } from "node:test"
import assert from "node:assert/strict"
import { matches, normalize } from "../../app/javascript/lib/filter.js"

test("every word has to match, in any order", () => {
  assert.equal(matches("Chickpea and Spinach Curry", "curry spin"), true)
  assert.equal(matches("Chickpea and Spinach Curry", "curry lamb"), false)
})

test("ignores case and accents", () => {
  assert.equal(normalize("  Crème Brûlée "), "creme brulee")
  assert.equal(matches("Crème brûlée", "CREME"), true)
})

test("an empty query matches everything", () => {
  assert.equal(matches("Anything", "   "), true)
})
