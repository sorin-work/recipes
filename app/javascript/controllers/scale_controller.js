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
}
