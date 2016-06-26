require_relative 'folder_parser'
require_relative 'order_creator'

#path = 'E:/Wsl_F/test2'
#path = 'E:/vstup/2015'        #all
#path = 'E:/vstup/2015/41'     #KNU
#path = 'E:/vstup/2015/174'    #KPI
#path = 'E:/vstup/2015/79'     #NaUKMA
#path = 'E:/vstup/2015/183'    #NAU
#path = 'E:/vstup/2015/194'    #Dragomanova
path = 'E:/vstup/combo'

univ_caption = 'KNU+KPI+NaUKMA+NAU'
result_path = 'E:/ProgramingProjects/Ruby/parseVstup2015/res/'
fp = Folder_parser.new

specialities = fp.parse(path)
fp.print_res("#{result_path}#{univ_caption}_res.csv")
#fp.print_all_good_specialities_names
fp.print_statistic
fp.print_statistic_to_file("#{result_path}#{univ_caption}_statistic.txt")

order_creator = Order_creator.new(specialities)
order_creator.create_orders("#{result_path}#{univ_caption}_orders.csv")

#fp.delete_files
