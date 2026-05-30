import { Controller } from "@hotwired/stimulus"
import { matches } from "lib/filter"

// Hides list items that don't match what is typed in the input.
export default class extends Controller {
  static targets = ["input", "item"]

  filter() {
    const query = this.inputTarget.value
    for (const item of this.itemTargets) {
      item.hidden = !matches(item.dataset.filterText || item.textContent, query)
    }
  }
}
