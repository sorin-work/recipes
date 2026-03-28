class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Recipes <recipes@localhost>")
  layout "mailer"
end
