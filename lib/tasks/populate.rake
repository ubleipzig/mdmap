# namespace :db do
#   desc "Erase and fill database"
#   task :populate => :environment do
#     require 'populator'
#     require 'faker'
    
#     [Edition].each(&:delete_all)
    
#     Edition.populate 20 do |edition|
#       edition.name = Populator.words(1..3).titleize
#       Oclc.create do |oclc|
#       	oclc.
#     end
    
#     Person.populate 100 do |person|
#       person.name    = Faker::Name.name
#       person.company = Faker::Company.name
#       person.email   = Faker::Internet.email
#       person.phone   = Faker::PhoneNumber.phone_number
#       person.street  = Faker::Address.street_address
#       person.city    = Faker::Address.city
#       person.state   = Faker::Address.us_state_abbr
#       person.zip     = Faker::Address.zip_code
#     end
#   end
# end