class Student
  attr_reader :name, :priority, :zno, :certificate

  def initialize(name, priority, zno, certificate)
    @name = name
    @priority = priority
    @zno = zno
    @certificate = certificate
  end

  def to_s
    "name: #{@name} \t priority: #{@priority} \t zno: #{@zno}"
  end
end