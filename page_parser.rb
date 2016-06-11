require 'open-uri'
require 'nokogiri'

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

    doc.css('#list .container .row .tablesaw.tablesaw-stack tbody tr td').each do |node|
      if node.text.include?('Обсяг державного замовлення')
        puts "size: #{node.text[/\d+/].to_i}"
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

    n= names.length
    (0..n-1).each { |i|
      puts "name: #{names[i]}       pr: #{prior[i]}       zno: #{zno[i]}"
    }

  end

end


#path = 'E:\\vstup2015\\vstup.info\\2015\\976\\i2015i976p202686.html'
#path = 'E:\\vstup2015\\vstup.info\\2015\\288\\i2015i288p255754.html'
path = 'http://vstup.info/2015/41/i2015i41p240447.html'
#path = 'http://vstup.info/2015/41/i2015i41p247726.html#list'

Page_parser.parse(path)