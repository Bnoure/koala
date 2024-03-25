import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-form"
export default class extends Controller {
  static targets = [ "content" ]
  connect() {
    console.log('Hello, Stimulus!')
  }

  checkLength() {
    if (this.contentTarget.value.length > 500) {
      alert('Votre commentaire ne peut pas dépasser 180 caractères.');
    }
  }
}
