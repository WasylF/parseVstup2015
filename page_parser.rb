require 'open-uri'
require 'nokogiri'

class Page_parser

  #path - url or path on drive to html file
  def self.parse(path)
    doc = Nokogiri::HTML(open(path))
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