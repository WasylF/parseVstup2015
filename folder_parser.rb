require_relative 'page_parser'

class Folder_parser

  def initialize
    @all_priorities = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @total_state_order_volume = 0
    @res = []
    @specialities = []
  end


  def get_all_files(folder_path)
    files = []
    dirs = []
    Dir.chdir(folder_path)
    Dir["*"].each { |path|
      if File.directory?(path)
        dirs << "#{folder_path}/#{path}"
      else
        if path.end_with?('.html') || path.end_with?('.htm')
          files << "#{folder_path}/#{path}"
        end
      end
    }

    dirs.each { |dir|
      files += get_all_files(dir)
    }

    return files
  end


  def to_string(cur_spec, name, priority, zno, other_spec)
    if cur_spec.nil? || name.nil? || priority.nil? || zno.nil? || other_spec.nil?
      return nil
    end
    " ;#{cur_spec};#{name};#{priority};#{zno};#{other_spec}"
  end


  def state_to_string(student, speciality)
    cur_spec = "#{speciality.university}_#{speciality.caption}"
    name = "#{student.name}_#{student.certificate}"
    priority = "#{student.priority}"
    zno = "#{student.average_zno}"
    other_spec = ""

    to_string(cur_spec, name, priority, zno, other_spec)
  end


  def not_state_to_string(student, speciality)
    cur_spec = ""
    name = "#{student.name}_#{student.certificate}"
    priority = "#{student.priority}"
    zno = "#{student.average_zno}"
    other_spec = "#{speciality.university}_#{speciality.caption}"

    to_string(cur_spec, name, priority, zno, other_spec)
  end


  def process_state_students(speciality)
    state_students = speciality.get_state_students

    if state_students.nil?
      return false
    end

    @total_state_order_volume += speciality.volume

    state_students.each { |student|
      s = state_to_string(student, speciality)
      if s.nil?
        return false
      end

      pr = student.priority.to_i
      if pr.nil?
        return false
      end

      @all_priorities[pr] += 1
      @res << s
    }

    true
  end


  def process_other_students(speciality)
    other_students = speciality.get_not_state

    if other_students.nil?
      return false
    end

    other_students.each { |student|
      s = not_state_to_string(student, speciality)
      if s.nil?
        return false
      end
      @res << s
    }

    true
  end


  def process_speciality(speciality)
    if speciality.nil?
      return false
    end

    if !speciality.has_state_order?
      return false
    end

    process_other_students(speciality)
    return process_state_students(speciality)
  end


  def parse(folder_path)
    files = get_all_files(folder_path)

    @total_files_number = files.length
    puts "\n\ntotal number of files: #{@total_files_number}\n\n"

    index = 0
    files.each { |file|
      if index % 1000 == 0
        puts "#{index} files have been parsed"
      end
      index += 1

      page_parser = Page_parser.new(file)
      speciality = page_parser.parse
      if process_speciality(speciality)
        @specialities << speciality
      end
    }

    puts "#{@total_files_number} files have been parsed\n"
  end


  def print_res(file_name)
    File.open(file_name, 'w') { |file|
      @res.each { |line|
        file.write("#{line}\n")
      }
    }
  end

  def print_statistic
    puts '#############################################################################################################'
    puts '#############################################################################################################'
    puts '*                                           S T A T I S T I C                                               *'
    puts '*************************************************************************************************************'

    puts "total number of files: #{@total_files_number}"
    puts "total bachelor specialities: #{@specialities.length}"
    puts "\n"

    total_with_priorities = 0
    (1..15).each { |i|
      total_with_priorities+= @all_priorities[i]
    }
    puts "total state order volume: #{@total_state_order_volume}"
    puts "students with priorities: #{total_with_priorities}"
    puts "\n"

    puts 'students that entered university with priority:'
    (1..15).each { |i|
      puts " #{i}\t\t#{@all_priorities[i]}"
    }
    puts "\n"

    missed_all = Page_parser.get_missed_all
    missed_priority = Page_parser.get_missed_priority
    missed_name = Page_parser.get_missed_name
    missed_zno = Page_parser.get_missed_zno
    missed_certificate = Page_parser.get_missed_certificate

    puts "totally wrong tables: #{missed_all}"
    puts "missed priorities: #{missed_priority}"
    puts "missed names: #{missed_name}"
    puts "missed znos: #{missed_zno}"
    puts "missed certificates: #{missed_certificate}"
    puts "\n"

    puts '*************************************************************************************************************'
    puts '*                                      E N D      S T A T I S T I C                                         *'
    puts '#############################################################################################################'
    puts '#############################################################################################################'
  end


end

path = 'E:/Wsl_F/test2/'
#path = 'E:/vstup/'
fp = Folder_parser.new

fp.parse(path)
fp.print_statistic
fp.print_res('E:\ProgramingProjects\Ruby\parseVstup2015\res.csv')