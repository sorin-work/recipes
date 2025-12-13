import { Controller } from "@hotwired/stimulus"
import { debounce } from "lib/debounce"

// Submits its form when a field changes, or shortly after typing stops.
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.submitLater = debounce(() => this.submit(), this.delayValue)
  }

  disconnect() {
    this.submitLater.cancel()
  }

  submit() {
    this.element.requestSubmit()
  }
}
