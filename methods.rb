def get_subject_teachers(id, client)
    f = "SELECT s.name ,t.first_name,t.middle_name,t.last_name  
    FROM teachers_erik t 
    JOIN subjects_erik s 
      ON t.subjects_id=s.id
      WHERE s.id = #{id}"
    results = client.query(f).to_a
    if results.count.zero?
      puts "Teacher with ID #{id} was not found."
    else
      output = "Subject: #{results[0]["name"]}\nTeacher:"
      results.each do |row|
        output += "\n#{row["first_name"]} #{row["middle_name"]} #{row["last_name"]}"
      end
      puts output
    end
end

def get_class_subjects(id, client)
    f = "SELECT c.name class, 
    s.name subject , t.first_name name, t.middle_name ,t.last_name
  FROM classes_erik c 
  JOIN teachers_classes_erik tc 
    ON tc.class_id = c.id 
  JOIN teachers_erik t 
    ON t.id = tc.teacher_id 
  JOIN subjects_erik s 
    ON s.id = t.subjects_id
    WHERE c.id = #{id}"
    results = client.query(f).to_a
    if results.count.zero?
      puts "Teacher with ID #{id} was not found."
    else
      output = "Class: #{results[0]["class"]}\nSubjects:"
      results.each do |row|
        output += "\n#{row["subject"]} (#{row["name"]} #{row["middle_name"][0]}. #{row["last_name"]})"
      end
    puts output
    end
end

def get_teachers_list_by_letter(letter, client)
    letter = letter.upcase
    f = "SELECT s.name ,t.first_name,t.middle_name,t.last_name  
    FROM teachers_erik t 
    JOIN subjects_erik s 
      ON t.subjects_id=s.id
      WHERE t.first_name like '#{letter}%'"
    results = client.query(f).to_a
    if results.count.zero?
      puts "Teacher with ID #{id} was not found."
    else
      output = ""
      results.each do |row|
        output += "\n#{row["first_name"]} #{row["middle_name"][0]}. #{row["last_name"]} (#{row["name"]})"
      end
      puts output
    end
end

def set_md5(id, client)
  f = "SELECT * from teachers_erik"
  results = client.query(f).to_a
  results.each do |el|
    o = Digest::MD5.hexdigest "#{el['first_name']}#{el['middle_name']}#{el['last_name']}#{el['birth_date']}#{el['subjects_id']}#{el['current_age']}"
    client.query("UPDATE teachers_erik SET md5 = '#{o}' WHERE id = #{el['id']}")
end
end

def get_class_info(id, client)
  f = "SELECT t.id, c.name class, 
  t.first_name name, t.middle_name ,t.last_name, c.responsible_teacher_id
FROM classes_erik c 
JOIN teachers_classes_erik tc 
  ON tc.class_id = c.id 
JOIN teachers_erik t 
  ON t.id = tc.teacher_id 
  WHERE c.id = #{id};"
  
results = client.query(f).to_a
r_teacher = results.find { |el| el['id']==el['responsible_teacher_id'] }
    
if results.count.zero?
  puts "Class with ID #{id} was not found."
else
  output = "Class: #{results[0]['class']}\nResponsible teacher: #{r_teacher['name']} #{r_teacher['middle_name']} #{r_teacher['last_name']}\n"
  output += "Involved teachers:"
  results.each do |x|
    output += " #{x['name']} #{x['middle_name']} #{x['last_name']},"
  end
  puts output.chop!
end
end

def get_teachers_by_year(year, client)
  if results.count.zero?
    puts "Teacher has born in #{year} was not found."
  else
  f = "SELECT YEAR(birth_date),first_name, middle_name ,last_name 
  FROM teachers_erik 
  WHERE YEAR(birth_date) = #{year};"
  results = client.query(f).to_a
  output = "Teachers born in #{year}:"
  results.each do |x|
    output += " #{x['first_name']} #{x['middle_name']} #{x['last_name']},"
  end
  end
  puts output.chop!
end
  
def random_date(date_begin,date_end,client)
  output = rand(Date.parse(date_begin)..Date.parse(date_end)).to_s
  return output
end

def random_last_names(n,client)
  f = "SELECT last_name
  FROM last_names"
  @res = @res ? @res : client.query(f).to_a.map(&:values).map {|el| el[0]}
  result =[]
  n.times do 
   result << @res.sample
  end
  return result
end

def random_first_names(n,client)
  f = "SELECT FirstName m_name
  FROM male_names 
  UNION 
  SELECT names f_name
  FROM female_names"
  @res2 = @res2 ? @res2 : client.query(f).to_a.map(&:values).map {|el| el[0]}
  result =[]
  n.times do
    result << @res2.sample
  end
  return result
end

def random_people(n,client)
  rfn = random_first_names(n,client)
  rln = random_last_names(n,client)
  rbd = [] 
  n.times{rbd << random_date("1910-01-01","2022-12-31",client)}
  res = []
  rfn.each_with_index do |row, ind|
    res << [row, rln[ind], rbd[ind]]
  end
  res.each_slice(20000) do |res_|
    insert = "INSERT INTO random_people_erik(first_name,last_name,birth_date)
    VALUES "
    res_.each do |fn_ln_bd|
        insert += "(\"#{fn_ln_bd[0]}\",\"#{fn_ln_bd[1]}\",\"#{fn_ln_bd[2]}\"),"
    end
    client.query(insert.chop!)
  end
end

def clean_name(client)
    f = "select school_name,address,city,state,zip from montana_public_district_report_card;"
    r = client.query(f).to_a
    output = "INSERT INTO montana_public_district_report_card__uniq_dist_erik(clean_name,name,address,city,state,zip) VALUES"
    r.each do |x|
      r2 = x['school_name'].gsub(/\b(Elem|El)\b/,'Elementary School').gsub(/\bH ?S\b/,'High School').
      gsub(/K-12( Schools| Schls)?/,'Public School').gsub(/(\b\w+\b) \1/,'\1')
      output += "(\"#{r2} District\" ,\'#{x['school_name']}\',\'#{x['address']}\',\'#{x['city']}\',\'#{x['state']}\',\'#{x['zip']}\'),"  
    end
  client.query(output.chop!)
end

def clean_office_names(client)
  f = "SELECT candidate_office_name FROM hle_dev_test_candidates"
  q = client.query(f).to_a
  name = []
  clean_name = []
  output = "INSERT INTO hle_dev_test_erik_nascimento(candidate_office_name,clean_name,sentence) VALUES"    
  q.each do |x|
      name = x['candidate_office_name']
      clean_name = name.gsub("Twp","Township").gsub("Hwy","Highway").gsub(".","")
      if name.split("/").count >= 3
        clean_name = clean_name.split("/")
        clean_name = clean_name.map(&:downcase)
        clean_name[-1] = clean_name[-1].split(" ").map(&:capitalize).join(" ")
        clean_name.unshift(clean_name[2]).delete_at(-1)
        clean_name = clean_name.join(" ").gsub(/(\b\w+\b) \1/i,'\1').split(" ").insert(3,"and").join(" ")
      elsif name.count("/") >= 1
        clean_name = clean_name.split("/")
        clean_name[0] = clean_name[0].split(" ").map(&:downcase).join(" ")
        clean_name = clean_name.reverse.join(" ").gsub(/(\b\w+\b) \1/i,'\1').strip
        if name.include?(',')
          clean_name = clean_name.split(',')
          clean_name[-1] = clean_name[-1].strip
          clean_name[-1] = clean_name[-1].split(" ").map(&:capitalize).join(" ")
          clean_name[-1] = "(#{clean_name[-1]})"
          clean_name = clean_name.join(" ")
         end
      else
       if name.include?(',')
        clean_name = clean_name.split(',')
        clean_name[-1] = clean_name[-1].strip
        clean_name[-1] = "(#{clean_name[-1]})"
        clean_name[0] = clean_name[0].downcase
        clean_name = clean_name.join(" ")
       else
        clean_name = name.downcase.gsub(".","")
       end
      end
      output += "(\"#{name}\",\"#{clean_name}\",\"The candidate is running for the #{clean_name} office.\"),"
  end
  client.query(output.chop!)
end

def noko_giri_covid_chart(client)
  document = Nokogiri::HTML(open("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html"))
  table = document.at("tbody").text.split("\n").join(" ").strip.split("  ")
  output = "INSERT INTO covid_test_chart_erik(week,spec_tested_total,pos_total,spec_tested_between_0_and_4_years,pos_between_0_and_4_years,spec_tested_between_5_and_17_years,
  pos_between_5_and_17_years,spec_tested_between_18_and_49_years,pos_between_18_and_49_years,spec_tested_between_50_and_64_years,
  pos_between_50_and_64_years,spec_tested_over_65_years,pos_over_65_years) VALUES"
  table.each do |x|
    x = x.split(" ")
    x.map!{|y|y.gsub(",","")}
    output+= "(#{x[0]},#{x[1]},'#{x[2]}',#{x[3]},'#{x[4]}',#{x[5]},'#{x[6]}',#{x[7]},'#{x[8]}',#{x[9]},'#{x[10]}',#{x[11]},'#{x[12]}'),"
  end
  client.query(output.chop!)
end