require 'open-uri'
require 'nokogiri'
require_relative 'speciality'
require_relative 'student'


class Page_parser
  @@missed_all = 0
  @@missed_priority = 0
  @@missed_name = 0
  @@missed_zno = 0
  @@missed_certificate = 0

  class << self
    def get_missed_all
      @@missed_all
    end

    def get_missed_priority
      @@missed_priority
    end

    def get_missed_name
      @@missed_name
    end

    def get_missed_zno
      @@missed_zno
    end

    def get_missed_certificate
      @@missed_certificate
    end

    def inc_missed_all
      @@missed_all += 1
    end

    def inc_missed_priority
      @@missed_priority += 1
    end

    def inc_missed_name
      @@missed_name += 1
    end

    def inc_missed_zno
      @@missed_zno += 1
    end

    def inc_missed_certificate
      @@missed_certificate += 1
    end
  end

  def initialize(file_path)
    @path = file_path

    @names = []
    @prior = []
    @zno = []
    @certificate = []

    @state_order_volume = 0

  end

  def check_format(doc)
    headers = []
    doc.xpath('//*/table/thead/tr/th').each do |th|
      headers << th.text
    end

    if !headers.include?('ПІБ') && !headers.include?('П') && !headers.include?('ЗНО') && !headers.include?('С')
      puts 'totally wrong table format!'
      puts "file_name: #{@path}"
      Page_parser.inc_missed_all
      return false
    end

    @headers_size = headers.length
    return check_headers(headers)
  end

  def check_headers(headers)
    flag = true
    if !headers.include?('П') #not a bachelor
      Page_parser.inc_missed_priority
      flag = false
    else
      @priority_index = headers.index('П')
    end

    if headers.include?('ПІБ')
      @name_index = headers.index('ПІБ')
    else
      Page_parser.inc_missed_name
      flag = false
    end

    if headers.include?('ЗНО')
      @zno_index = headers.index('ЗНО')
    else
      Page_parser.inc_missed_zno
      flag = false
    end

    if headers.include?('С')
      @certificate_index = headers.index('С')
    else
      Page_parser.inc_missed_certificate
      flag = false
    end

    flag
  end


  def parse_table(doc)
    cur_i= -3

    doc.css('#list .container .row .tablesaw.tablesaw-stack tbody tr td').each do |node|
      if node.text.include?('Обсяг державного замовлення')
        @state_order_volume = node.text[/\d+/].to_i
        cur_i = -2
      else
        #last line before table
        if cur_i == -2 && node.text.include?('Конкурс на бюджет:')
          cur_i = -1
        else
          #first line in table
          if cur_i == -1 && node.text == '1'
            cur_i = 1
          else
            #any line in table
            if cur_i >= 0
              case cur_i
                when @name_index
                  @names << node.text
                when @priority_index
                  @prior << node.text
                when @zno_index
                  @zno << node.text
                when @certificate_index
                  @certificate << node.text
              end

              cur_i += 1
              if cur_i == @headers_size
                cur_i = 0
              end
            end
          end
        end
      end
    end

  end

  #path - url or path on drive to html file
  def parse
    doc = Nokogiri::HTML(open(@path))

    if !check_format(doc)
      return
    end

    parse_table(doc)

    title = doc.css('.sticky-nav')[0]
    specialisation = title.css('li a')[0]['title']
    university = title.css('li a')[1]['title']

    speciality = Speciality.new(specialisation, university, @state_order_volume)
    n = @names.length
    (0 .. n-1).each { |i|
      student = Student.new(@names[i], @prior[i], @zno[i], @certificate[i])
      speciality.add_student(student)
    }

    speciality
  end

end


#path = 'E:\\vstup2015\\vstup.info\\2015\\976\\i2015i976p202686.html'
#path = 'E:\\vstup2015\\vstup.info\\2015\\288\\i2015i288p255754.html'
#path = 'http://vstup.info/2015/41/i2015i41p240447.html'
#path = 'http://vstup.info/2015/41/i2015i41p247726.html#list'
#path = 'http://vstup.info/2015/79/i2015i79p207709.html#list'
#path = 'http://vstup.info/2015/174/i2015i174p212763.html#list'
#path = 'E:/Wsl_F/test/2/i2015i2p255724.html'
#path = 'http://vstup.info/2015/357/i2015i357p230569.html'
#path = 'E:/vstup2015/vstup.info/2015/1004/i2015i1004p272076.html'
#path = 'E:/Wsl_F/test/44/i2015i44p203910.html'
#page_parser = Page_parser.new(path)
#speciality = page_parser.parse

#puts speciality