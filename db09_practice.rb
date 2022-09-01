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
random_date("1995-03-12","2012-04-25",client)
random_last_names(3,client)
random_first_names(5,client)
random_people(10,client)
t = Time.now
1.times do
  puts random_people(10000,client)
end
puts Time.now - t

client.close