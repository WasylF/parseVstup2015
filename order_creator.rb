require_relative 'speciality'
require_relative 'student'

class Order_creator

  def initialize(specialities)
    @specialities = specialities

    @specialities_id = {}
    @students = []

    @specialities.each_with_index { |speciality, i|
      @specialities_id[speciality] = i
      speciality.get_state_students.each { |student|
        @students << "#{student.name}_#{student.certificate}"
      }
    }

    @students = @students.uniq
    @students_id = {}
    @students.each_with_index { |student_name, i|
      @students_id[student_name] = i
    }

    @student_spec = Array.new(@students.length)
    @marks = Array.new(@students.length, 0)
    @cur_priority = Array.new(@students.length)

    (0..@students.length-1).each { |i|
      @student_spec[i] = Array.new(16, -1)
    }

    @specialities.each_with_index { |speciality, i|
      speciality.get_state_students.each { |student|
        student_name = "#{student.name}_#{student.certificate}"
        student_id = @students_id[student_name]
        @marks[student_id] = student.average_zno
        speciality_id = i #@specialities_id[speciality]
        @student_spec[student_id][student.priority] = speciality_id
        @cur_priority[student_id] = student.priority
      }

      if !speciality.get_not_state.nil?
        speciality.get_not_state.each { |student|
          student_name = "#{student.name}_#{student.certificate}"
          if @students_id.has_key?(student_name)
            student_id = @students_id[student_name]
            speciality_id = i #@specialities_id[speciality]
            @student_spec[student_id][student.priority] = speciality_id
          end
        }
      end
    }

  end

  def create_orders(file_name)
    orders = []


    students_num = @students.length-1
    (0..students_num).each { |student_id|
      if @cur_priority[student_id] > 1
        closest_priority = @cur_priority[student_id]-1
        closest_priority.downto(1) { |priority|
          if @student_spec[student_id][priority] != -1
            name = @students[student_id]
            mark = @marks[student_id]
            cur_speciality = @specialities[@student_spec[student_id][@cur_priority[student_id]]].get_name
            dream_speciality = @specialities[@student_spec[student_id][priority]].get_name
            order = "#{name};#{mark};#{cur_speciality};#{dream_speciality};"

            orders << order
            break
          end
        }
      end
    }

    File.open(file_name, 'w') { |file|
      orders.each { |line|
        file.write("#{line}\n")
      }
    }

  end

  def create_multi_orders(file_name)
    orders = []

    (0..@students.length-1).each { |student_id|
      if @cur_priority[student_id] > 1
        (1..@cur_priority[student_id]-1).each { |priority|
          if @student_spec[student_id][priority] != -1
            name = @students[student_id]
            mark = @marks[student_id]
            cur_speciality = @specialities[@student_spec[student_id][@cur_priority[student_id]]].get_name
            dream_speciality = @specialities[@student_spec[student_id][priority]].get_name
            order = "#{name};#{mark};#{cur_speciality};#{dream_speciality}"

            orders << order
          end
        }
      end
    }

    File.open(file_name, 'w') { |file|
      orders.each { |line|
        file.write("#{line}\n")
      }
    }

  end
end