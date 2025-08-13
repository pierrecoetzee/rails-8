# Pin npm packages by running ./bin/importmap
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js"
pin "@hotwired/turbo", to: "@hotwired--turbo.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin "@rails/actioncable", to: "@rails--actioncable--src.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"