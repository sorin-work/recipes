import { Controller } from "@hotwired/stimulus"

// Notices fade out after a few seconds; alerts stay until dismissed.
export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    if (this.element.classList.contains("flash--notice")) {
      this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
    }
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.add("is-leaving")
    setTimeout(() => this.element.remove(), 200)
  }
}
