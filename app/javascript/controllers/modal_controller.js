import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
static targets = ["dialog", "x"]

connect() {
  this.xTarget.style.display = 'none';
}

open() {
  this.dialogTarget.showModal();
  this.xTarget.style.display = 'block';
}

close() {
  this.dialogTarget.close();
  this.xTarget.style.display = 'none';
}

}
