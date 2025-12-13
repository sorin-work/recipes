// Returns a function that runs `fn` once calls have stopped for `wait` ms.
// The returned function has a `cancel()` to drop a pending call.
export function debounce(fn, wait = 300, timers = globalThis) {
  let timeout = null

  const debounced = (...args) => {
    if (timeout !== null) timers.clearTimeout(timeout)
    timeout = timers.setTimeout(() => {
      timeout = null
      fn(...args)
    }, wait)
  }

  debounced.cancel = () => {
    if (timeout !== null) timers.clearTimeout(timeout)
    timeout = null
  }

  return debounced
}
