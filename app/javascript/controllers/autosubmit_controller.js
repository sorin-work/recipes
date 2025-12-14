import { Controller } from "@hotwired/stimulus"
import { debounce } from "lib/debounce"

// Submits its form when a field changes, or shortly after typing stops.
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.submitLater = debounce(() => this.submit(), this.delayValue)
    this.submitted = this.serialize()
  }

  disconnect() {
    this.submitLater.cancel()
  }

  submit() {
    // The search box fires "change" again when it loses focus, e.g. when a result
    // is clicked. Submitting the same search again would cancel that click.
    const data = this.serialize()
    if (data === this.submitted) return
    this.submitted = data
    this.element.requestSubmit()
  }

  serialize() {
    return new URLSearchParams(new FormData(this.element)).toString()
  }
}
