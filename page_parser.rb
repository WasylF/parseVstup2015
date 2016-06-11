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
      puts 'wrong table formate!'
      return
    else
      name_index = headers.index('ПІБ')
      priority_index = headers.index('П')
      zno_index = headers.index('ЗНО')
      headers_size = headers.length
    end


    doc.css('#list .container .row .tablesaw.tablesaw-stack tbody tr td').each do |node|
      if node.text.include?('Обсяг державного замовлення')
        puts "size: #{node.text[/\d+/].to_i}"
      end
    end
  end

end





#path = 'E:\\vstup2015\\vstup.info\\2015\\976\\i2015i976p202686.html'
#path = 'E:\\vstup2015\\vstup.info\\2015\\288\\i2015i288p255754.html'
path = 'http://vstup.info/2015/41/i2015i41p240447.html'
#path = 'http://vstup.info/2015/41/i2015i41p247726.html#list'

Page_parser.parse(path)