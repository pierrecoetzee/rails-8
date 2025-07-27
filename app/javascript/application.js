// Import Turbo for page navigation
import "@hotwired/turbo-rails"

// Import all controllers
import "controllers"

// Import and start Stimulus
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }