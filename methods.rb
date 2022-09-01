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