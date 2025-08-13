console.log("=== APPLICATION.JS LOADED ===")

// Import Turbo for page navigation
import "@hotwired/turbo-rails"

// Import all controllers
import "controllers"

// Import channels
import "channels/consumer"
import "channels/user_stats_channel"

console.log("IMPORTS COMPLETED!")

// Import and start Stimulus
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }