require 'mysql2'
require 'dotenv/load'
require 'digest'
require_relative 'methods.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")


clean_office_names(client)

client.close