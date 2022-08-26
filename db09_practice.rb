require 'mysql2'
require 'dotenv/load'
require_relative 'methods.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

get_subject_teachers(2, client)
puts "-" * 50
get_class_subjects(1, client)
puts "-" * 50
get_teachers_list_by_letter("C",client)

client.close