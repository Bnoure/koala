import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "list" ]
  currentIndex = 0

  connect() {
    console.log(this.listTargets)
    console.log('hello from listof_controller.js!')
  }

  initialize() {
    // Hide all posts
    this.listTargets.forEach(post => post.style.display = 'none');

    // Show first 3 posts
    this.listTargets.slice(0, 4).forEach(post => post.style.display = 'block');
  }

  loadNext(event) {
    event.preventDefault();

    // Hide all posts
    this.listTargets.forEach(post => post.style.display = 'none');

    // Increase currentIndex by 3
    this.currentIndex += 4;

    // If currentIndex exceeds the length of the list, reset it to 0
    if (this.currentIndex >= this.listTargets.length) {
      this.currentIndex = 0;
    }

    // Show next posts
    this.listTargets.slice(this.currentIndex, this.currentIndex + 4).forEach(post => post.style.display = 'block');
  }

  loadPrevious(event) {
    event.preventDefault();

    // If already at the start of the list, do nothing
    if (this.currentIndex === 0) {
      return;
    }

    // Hide all posts
    this.listTargets.forEach(post => post.style.display = 'none');

    // Decrease currentIndex by 4
    this.currentIndex -= 4;

    // If currentIndex becomes negative, set it to the length of the list minus 4
    if (this.currentIndex < 0) {
      this.currentIndex = Math.max(this.listTargets.length - 4, 0);
    }

    // Show previous posts
    this.listTargets.slice(this.currentIndex, this.currentIndex + 4).forEach(post => post.style.display = 'block');
  }
}
