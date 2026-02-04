// What is being dragged on the planner: a recipe from the sidebar (to add) or
// an entry already on the plan (to move). Carried in the drag event under our
// own type so text or files dragged in from elsewhere are ignored.
export const DRAG_TYPE = "application/x-recipes-plan"

const KINDS = new Set(["recipe", "entry"])

export function encodeDragData({ type, id }) {
  if (!KINDS.has(type)) throw new Error(`Unknown drag type: ${type}`)
  return JSON.stringify({ type, id: String(id) })
}

// Returns { type, id } or null for anything that isn't ours.
export function decodeDragData(raw) {
  if (!raw) return null
  try {
    const data = JSON.parse(raw)
    if (!KINDS.has(data.type) || !/^\d+$/.test(String(data.id))) return null
    return { type: data.type, id: String(data.id) }
  } catch {
    return null
  }
}

export function hasDragData(dataTransfer) {
  return Boolean(dataTransfer) && Array.from(dataTransfer.types || []).includes(DRAG_TYPE)
}
