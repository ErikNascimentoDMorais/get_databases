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



  