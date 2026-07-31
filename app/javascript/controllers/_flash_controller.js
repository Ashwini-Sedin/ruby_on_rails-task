import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Automatically dismiss the popup after 15 seconds (15000ms)
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 15000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    // Smooth fade-out animation
    this.element.style.transition = "opacity 0.5s ease, transform 0.5s ease"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-10px)"
    
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
