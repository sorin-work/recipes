import { Controller } from "@hotwired/stimulus"

// Opens and closes the main navigation on small screens.
export default class extends Controller {
  static targets = ["button", "menu"]

  toggle() {
    const open = this.buttonTarget.getAttribute("aria-expanded") !== "true"
    this.buttonTarget.setAttribute("aria-expanded", String(open))
    this.menuTarget.classList.toggle("is-open", open)
  }
}
