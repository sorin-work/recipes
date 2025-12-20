import { Controller } from "@hotwired/stimulus"
import { formatAmount, scaleFactor } from "lib/quantities"

// Rescales the ingredient amounts on a recipe page as the servings change.
export default class extends Controller {
  static targets = ["input", "amount"]
  static values = { base: Number }

  update() {
    const factor = scaleFactor(this.inputTarget.value, this.baseValue)
    for (const amount of this.amountTargets) {
      const { quantity, style, unit, unitPlural } = amount.dataset
      amount.textContent = formatAmount(Number(quantity) * factor, { style, unit, unitPlural })
    }
    this.updateUrl()
  }

  increment() {
    this.step(1)
  }

  decrement() {
    this.step(-1)
  }

  step(by) {
    const current = Number(this.inputTarget.value) || this.baseValue
    this.inputTarget.value = current + by
    this.update()
  }

  // Keep ?servings= in the address bar so a reload or a shared link keeps the scale.
  updateUrl() {
    const url = new URL(window.location.href)
    const servings = Number(this.inputTarget.value)
    if (servings === this.baseValue || !servings) url.searchParams.delete("servings")
    else url.searchParams.set("servings", servings)
    window.history.replaceState(window.history.state, "", url)
  }
}
