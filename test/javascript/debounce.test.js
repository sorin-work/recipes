import { test } from "node:test"
import assert from "node:assert/strict"
import { debounce } from "../../app/javascript/lib/debounce.js"

function fakeTimers() {
  const timers = new Map()
  let next = 1
  return {
    setTimeout(fn, wait) {
      const id = next++
      timers.set(id, { fn, wait })
      return id
    },
    clearTimeout(id) {
      timers.delete(id)
    },
    flush() {
      for (const [id, { fn }] of timers) {
        timers.delete(id)
        fn()
      }
    },
    get pending() {
      return timers.size
    },
  }
}

test("runs once after calls stop", () => {
  const timers = fakeTimers()
  const calls = []
  const debounced = debounce((value) => calls.push(value), 300, timers)

  debounced("a")
  debounced("ab")
  debounced("abc")
  assert.equal(timers.pending, 1)

  timers.flush()
  assert.deepEqual(calls, ["abc"])
})

test("cancel drops the pending call", () => {
  const timers = fakeTimers()
  const calls = []
  const debounced = debounce(() => calls.push("x"), 300, timers)

  debounced()
  debounced.cancel()
  timers.flush()
  assert.deepEqual(calls, [])
})

test("uses the real timers by default", async () => {
  let called = false
  const debounced = debounce(() => (called = true), 5)
  debounced()
  await new Promise((resolve) => setTimeout(resolve, 20))
  assert.equal(called, true)
})
