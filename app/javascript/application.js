// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"


document.addEventListener('DOMContentLoaded', function() {
  const commentInput = document.querySelector('#comment_content');
  const form = document.querySelector('form.new_comment');

  form.addEventListener('submit', function(e) {
    if (commentInput.value.length > 180) {
      e.preventDefault();
      alert('Votre commentaire ne peut pas dépasser 180 caractères.');
    }
  });
});
