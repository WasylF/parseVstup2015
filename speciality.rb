class Speciality
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
end