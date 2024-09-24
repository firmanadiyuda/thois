import { Controller } from "@hotwired/stimulus"
import { v4 as uuidv4 } from 'uuid';

// Connects to data-controller="select-theme"
export default class extends Controller {
  static targets = ["aiTheme", "finishButton", "selectedThemeForm", "selectedThemeField"]

  initialize() {
    this.selected_theme = null
    this.finishButtonTarget.classList.add('hidden')
  }

  disconnect() {
  }

  selectTheme(event) {
    event.preventDefault()

    this.finishButtonTarget.classList.remove('hidden')
    const target = event.currentTarget.querySelector("img");
    const id = event.target.dataset.id;

    if (this.selected_theme === id) {
      return;
    }

    this.selected_theme = id

    this.aiThemeTargets.forEach(el => {
      if (el.dataset.id === this.selected_theme) {
        el.classList.add('border', 'border-4', 'border-sky-600');
      } else {
        el.classList.remove('border', 'border-4', 'border-sky-600');
      }
    });
  }

  finish() {
    this.selectedThemeFieldTarget.value = this.selected_theme
    this.selectedThemeFormTarget.requestSubmit()
  }
}