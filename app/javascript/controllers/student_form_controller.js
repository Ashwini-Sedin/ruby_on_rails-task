import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "name", "counter", "submit", "required" ]

  connect() {
    this.updateCounter()
    this.validate()
  }

  updateCounter() {
    if (this.hasNameTarget && this.hasCounterTarget) {
      const count = this.nameTarget.value.length
      this.counterTarget.textContent = count
    }
  }

  validate() {
    if (!this.hasSubmitTarget) return

    let isValid = true

    
    if (this.hasNameTarget) {
      if (this.nameTarget.value.trim() === "") {
        isValid = false
      }
    } else {
      isValid = false
    }

 
    if (this.hasRequiredTarget) {
      this.requiredTargets.forEach(element => {
        if (element.value.trim() === "") {
          isValid = false
        }
      })
    }

    this.submitTarget.disabled = !isValid
  }
}
