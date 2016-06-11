class Student
  attr_reader :name, :priority, :zno

  def initialize(name, priority, zno)
    @name = name
    @priority = priority
    @zno = zno
  end

  def to_s
    "name: #{@name} \t priority: #{@priority} \t zno: #{@zno}"
  end
end