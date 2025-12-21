import { test } from "node:test"
import assert from "node:assert/strict"
import { formatAmount, formatDecimal, formatFraction, formatQuantity, scaleFactor } from "../../app/javascript/lib/quantities.js"

// Same cases as test/models/quantity_test.rb, so browser and server agree.
test("fractions for cups, spoons and counts", () => {
  assert.equal(formatFraction(1.5), "1 1/2")
  assert.equal(formatFraction(1 / 3), "1/3")
  assert.equal(formatFraction(0.667), "2/3")
  assert.equal(formatFraction(3), "3")
  assert.equal(formatFraction(0.5), "1/2")
})

test("just under a whole number rounds up", () => {
  assert.equal(formatFraction(0.999), "1")
  assert.equal(formatFraction(2.98), "3")
})

test("decimal fallback when no kitchen fraction is close", () => {
  assert.equal(formatFraction(0.43), "0.43")
})

test("decimals for metric", () => {
  assert.equal(formatDecimal(250), "250")
  assert.equal(formatDecimal(1.25), "1.25")
  assert.equal(formatDecimal(12.5), "12.5")
  assert.equal(formatDecimal(1000 / 3), "333")
})

test("formatQuantity picks the style", () => {
  assert.equal(formatQuantity(0.75, "fraction"), "3/4")
  assert.equal(formatQuantity(0.75, "decimal"), "0.75")
  assert.equal(formatQuantity(null, "decimal"), "")
})

test("amounts with singular and plural units", () => {
  assert.equal(formatAmount(3, { style: "fraction", unit: "cup", unitPlural: "cups" }), "3 cups")
  assert.equal(formatAmount(0.75, { style: "fraction", unit: "cup", unitPlural: "cups" }), "3/4 cup")
  assert.equal(formatAmount(500, { style: "decimal", unit: "g", unitPlural: "g" }), "500 g")
  assert.equal(formatAmount(2, { style: "fraction" }), "2")
})

test("scale factor", () => {
  assert.equal(scaleFactor(8, 4), 2)
  assert.equal(scaleFactor("2", "4"), 0.5)
  assert.equal(scaleFactor("", 4), 1)
  assert.equal(scaleFactor(0, 4), 1)
})
