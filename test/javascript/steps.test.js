import { test } from "node:test"
import assert from "node:assert/strict"
import { clampStep, stepStatus } from "../../app/javascript/lib/steps.js"

test("stays within the steps", () => {
  assert.equal(clampStep(-1, 3), 0)
  assert.equal(clampStep(5, 3), 2)
  assert.equal(clampStep(1, 3), 1)
  assert.equal(clampStep(4, 0), 0)
})

test("status text", () => {
  assert.equal(stepStatus(0, 4), "Step 1 of 4")
  assert.equal(stepStatus(9, 4), "Step 4 of 4")
  assert.equal(stepStatus(0, 0), "")
})
