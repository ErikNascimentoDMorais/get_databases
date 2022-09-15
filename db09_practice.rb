require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'dotenv/load'
require 'csv'
require 'digest'
require_relative 'methods.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

file = Nokogiri::HTML(open("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html"))

noko_giri_covid_chart(file,client)

client.close