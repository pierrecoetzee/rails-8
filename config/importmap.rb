# Pin npm packages by running ./bin/importmap
pin "application"
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js"
pin "@hotwired/turbo", to: "@hotwired--turbo.js"  # Add this line
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin_all_from "app/javascript/controllers", under: "controllers"