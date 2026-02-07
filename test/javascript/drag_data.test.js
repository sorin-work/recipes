import { test } from "node:test"
import assert from "node:assert/strict"
import { DRAG_TYPE, decodeDragData, encodeDragData, hasDragData } from "../../app/javascript/lib/drag_data.js"

test("round trip", () => {
  const raw = encodeDragData({ type: "recipe", id: 42 })
  assert.deepEqual(decodeDragData(raw), { type: "recipe", id: "42" })
})

test("refuses unknown kinds when encoding", () => {
  assert.throws(() => encodeDragData({ type: "file", id: 1 }))
})

test("ignores anything that isn't ours", () => {
  assert.equal(decodeDragData(""), null)
  assert.equal(decodeDragData("just some text"), null)
  assert.equal(decodeDragData(JSON.stringify({ type: "recipe", id: "1; drop table" })), null)
  assert.equal(decodeDragData(JSON.stringify({ type: "user", id: 1 })), null)
})

test("hasDragData looks at the transfer types", () => {
  assert.equal(hasDragData({ types: ["text/plain", DRAG_TYPE] }), true)
  assert.equal(hasDragData({ types: ["Files"] }), false)
  assert.equal(hasDragData(null), false)
})
