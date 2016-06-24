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

  def average_zno
    values = @zno.split(' ')
    if values.length == 0
      values << 0.0
    end
    values.inject(:+).to_f / values.size.to_f
  end
end