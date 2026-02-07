import { Controller } from "@hotwired/stimulus"
import { DRAG_TYPE, encodeDragData, decodeDragData, hasDragData } from "lib/drag_data"
import { turboStreamRequest } from "lib/request"

// Drag recipes from the sidebar onto a day and meal, or drag planned meals to
// another slot. The server answers with turbo streams for the changed cells.
export default class extends Controller {
  static values = { createUrl: String, entryUrl: String }

  dragstart(event) {
    const source = event.currentTarget
    event.dataTransfer.setData(DRAG_TYPE, encodeDragData({ type: source.dataset.dragType, id: source.dataset.dragId }))
    event.dataTransfer.effectAllowed = source.dataset.dragType === "entry" ? "move" : "copy"
    this.dragging = source
    source.classList.add("is-dragging")
  }

  dragend(event) {
    event.currentTarget.classList.remove("is-dragging")
    this.dragging = null
  }

  dragover(event) {
    if (!hasDragData(event.dataTransfer)) return

    event.preventDefault()
    event.currentTarget.classList.add("is-drop-target")
  }

  dragleave(event) {
    // Moving over a meal inside the cell fires dragleave on the cell too.
    if (event.currentTarget.contains(event.relatedTarget)) return
    event.currentTarget.classList.remove("is-drop-target")
  }

  async drop(event) {
    event.preventDefault()
    const cell = event.currentTarget
    cell.classList.remove("is-drop-target")

    const data = decodeDragData(event.dataTransfer.getData(DRAG_TYPE))
    if (!data) return

    const slot = { on: cell.dataset.date, meal: cell.dataset.meal }
    let ok
    if (data.type === "recipe") {
      ok = await turboStreamRequest(this.createUrlValue, {
        body: { from_planner: 1, meal_plan_entry: { recipe_id: data.id, ...slot } },
      })
    } else {
      // Dropped back where it came from.
      if (cell.querySelector(`[data-drag-type="entry"][data-drag-id="${data.id}"]`)) return
      ok = await turboStreamRequest(this.entryUrlValue.replace(":id", data.id), {
        method: "PATCH",
        body: { from_planner: 1, meal_plan_entry: slot },
      })
    }

    // Something went wrong (a validation error or an expired session): reload
    // so the flash message explains it.
    if (!ok) window.Turbo.visit(window.location.href, { action: "replace" })
  }
}
