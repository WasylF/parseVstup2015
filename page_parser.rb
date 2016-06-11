require 'open-uri'
require 'nokogiri'
require_relative 'speciality'
require_relative 'student'

class Page_parser

  #path - url or path on drive to html file
  def self.parse(path)
    doc = Nokogiri::HTML(open(path))

    headers = []
    doc.xpath('//*/table/thead/tr/th').each do |th|
      headers << th.text
    end

    if !headers.include?('ПІБ') || !headers.include?('П') || !headers.include?('ЗНО')
      puts 'wrong table format!'
      return
    else
      name_index = headers.index('ПІБ')
      priority_index = headers.index('П')
      zno_index = headers.index('ЗНО')
      headers_size = headers.length
    end

    names = []
    prior = []
    zno = []
    cur_i= -3

    state_order_volume = 0
    doc.css('#list .container .row .tablesaw.tablesaw-stack tbody tr td').each do |node|
      if node.text.include?('Обсяг державного замовлення')
        state_order_volume = node.text[/\d+/].to_i
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
                when 0
                  rating = node.text[/\d+/].to_i
                  if rating > state_order_volume
                    break
                  end
                when name_index
                  names << node.text
                when priority_index
                  prior << node.text
                when zno_index
                  zno << node.text
              end

              cur_i += 1
              if cur_i == headers_size
                cur_i = 0
              end
            end
          end

        end
      end

    end

    title = doc.css('.sticky-nav')[0]
    specialisation = title.css('li a')[0]['title']
    university = title.css('li a')[1]['title']
    # puts "spec: #{specialisation}"
    # puts "univ: #{university}"
    # puts "state order volume: #{state_order_volume}"
    #
    # n= names.length
    # (0..n-1).each { |i|
    #   puts "name: #{names[i]}       pr: #{prior[i]}       zno: #{zno[i]}"
    # }

    speciality = Speciality.new(specialisation, university, state_order_volume)
    n = names.length
    (0 .. n-1).each { |i|
      student = Student.new(names[i], prior[i], zno[i])
      speciality.add_student(student)
    }

    speciality
  end

end


#path = 'E:\\vstup2015\\vstup.info\\2015\\976\\i2015i976p202686.html'
#path = 'E:\\vstup2015\\vstup.info\\2015\\288\\i2015i288p255754.html'
#path = 'http://vstup.info/2015/41/i2015i41p240447.html'
#path = 'http://vstup.info/2015/41/i2015i41p247726.html#list'
path = 'http://vstup.info/2015/79/i2015i79p207709.html#list'
#path = 'http://vstup.info/2015/174/i2015i174p212763.html#list'

speciality = Page_parser.parse(path)

puts speciality