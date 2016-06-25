class Speciality
  attr_reader :caption, :university, :volume

  def initialize(speciality, university, state_order_volume)
    @caption = speciality
    @university = university
    @volume = state_order_volume

    @students = []
  end

  def add_student(student)
    @students << student
  end

  def to_s
    text= "university: #{@university}\nspeciality: #{@caption}\nstate order volume: #{@volume}\n"
    @students.each { |student|
      text << student.to_s.concat("\n")
      #text << '\n'
    }
    text
  end

  def has_state_order?
    @volume > 0 && @students.length > 0
  end

  def get_state_students
    if !has_state_order?
      return
    end

    n = @volume < @students.length ? @volume : @students.length
    @students[0, n]
  end

  def get_not_state
    if @volume >= @students.length
      return
    end

    @students[@volume..-1]
  end

  def get_name
    "#{@university}_#{@caption}"
  end
end