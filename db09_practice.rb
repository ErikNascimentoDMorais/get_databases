require 'mysql2'
require 'dotenv/load'
require 'digest'
require_relative 'methods.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

get_subject_teachers(2, client)
get_class_subjects(1, client)
get_teachers_list_by_letter("C",client)
set_md5(1,client)
get_class_info(1,client)
get_teachers_by_year(2000, client)

client.close