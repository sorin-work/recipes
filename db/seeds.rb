# Seeds run on `bin/rails db:seed` and when `bin/rails db:prepare` creates the
# database. There is no reference data; the only thing to seed is the optional
# demo account (demo@example.com / demo-password), see lib/demo_data.rb.
if ENV["SEED_DEMO"] == "true"
  user = DemoData.load
  puts "Demo account ready: #{user.email_address} / #{DemoData::PASSWORD}" unless Rails.env.test?
end
