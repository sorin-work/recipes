import { Controller } from "@hotwired/stimulus"
import { clampStep, stepStatus } from "lib/steps"

// Cook mode: one highlighted step at a time and the screen kept awake.
export default class extends Controller {
  static targets = ["step", "status", "previous", "next"]

  connect() {
    this.index = 0
    this.show()
    this.keepAwake()
    this.onVisibilityChange = () => {
      if (document.visibilityState === "visible") this.keepAwake()
    }
    document.addEventListener("visibilitychange", this.onVisibilityChange)
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.onVisibilityChange)
    this.wakeLock?.release().catch(() => {})
    this.wakeLock = null
  }

  next() {
    this.index = clampStep(this.index + 1, this.stepTargets.length)
    this.show()
  }

  previous() {
    this.index = clampStep(this.index - 1, this.stepTargets.length)
    this.show()
  }

  select(event) {
    this.index = this.stepTargets.indexOf(event.currentTarget)
    this.show()
  }

  keydown(event) {

    if (event.key === "ArrowRight" || event.key === "ArrowDown" || event.key === " ") {
      event.preventDefault()
      this.next()
    } else if (event.key === "ArrowLeft" || event.key === "ArrowUp") {
      event.preventDefault()
      this.previous()
    }
  }

  show() {
    const count = this.stepTargets.length
    this.stepTargets.forEach((step, i) => {
      step.classList.toggle("is-current", i === this.index)
      step.classList.toggle("is-done", i < this.index)
    })
    this.stepTargets[this.index]?.scrollIntoView({ block: "center", behavior: "smooth" })
    if (this.hasStatusTarget) this.statusTarget.textContent = stepStatus(this.index, count)
    if (this.hasPreviousTarget) this.previousTarget.disabled = this.index === 0
    if (this.hasNextTarget) this.nextTarget.disabled = this.index >= count - 1
  }

  async keepAwake() {
    this.wakeLock = await navigator.wakeLock.request("screen")
  }
}
