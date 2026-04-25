// Index arithmetic for cook mode: which step comes next or before, staying in range.
export function clampStep(index, count) {
  if (count <= 0) return 0
  return Math.min(Math.max(index, 0), count - 1)
}

export function stepStatus(index, count) {
  if (count <= 0) return ""
  return `Step ${clampStep(index, count) + 1} of ${count}`
}
