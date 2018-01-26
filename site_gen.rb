#!/usr/bin/ruby -w
# encoding: utf-8
#require 'mysql2'
require './lib/connector-json.rb'
# require './logger'
# include Logger

def render_html(flats, days,output_file='flats.html')
  i = 0
  file = File.open(output_file, 'a')
  file.write("<HTML> <head><title>Flats</title>\n")
  file.write("<meta http-equiv=\'Content-Type\'\n
       content=\'text/html; charset=utf-8\'/>\n")
  file.write("<style>\n")
  file.write("table {\n")
  file.write("    border-spacing: 0;\n")
  file.write("    border: 1px solid #ddd;\n")
  file.write("}\n")
  file.write("\n")
  file.write("th {\n")
  file.write("    cursor: pointer;\n")
  file.write("}\n")
  file.write("\n")
  file.write("th, td {\n")
  file.write("    text-align: left;\n")
  file.write("    padding: 16px;\n")
  file.write("}\n")
  file.write("\n")
  file.write("tr:nth-child(even) {\n")
  file.write("    background-color: #f2f2f2\n")
  file.write("}\n")
  file.write("</style>\n")
  file.write("</head>\n")
  file.write("<body>\n")
  file.write('<script>')
  file.write("function sortTable(n) {\n")
  file.write("  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;\n")
  file.write("  table = document.getElementById(\"myTable\");\n")
  file.write("  switching = true;\n")
  file.write("  //Set the sorting direction to ascending:\n")
  file.write("  dir = \"asc\"; \n")
  file.write("  /*Make a loop that will continue until\n")
  file.write("  no switching has been done:*/\n")
  file.write("  while (switching) {\n")
  file.write("    //start by saying: no switching is done:\n")
  file.write("    switching = false;\n")
  file.write("    rows = table.getElementsByTagName(\"TR\");\n")
  file.write("    /*Loop through all table rows (except the\n")
  file.write("    first, which contains table headers):*/\n")
  file.write("    for (i = 1; i < (rows.length - 1); i++) {\n")
  file.write("      //start by saying there should be no switching:\n")
  file.write("      shouldSwitch = false;\n")
  file.write("      /*Get the two elements you want to compare,\n")
  file.write("      one from current row and one from the next:*/\n")
  file.write("      x = rows[i].getElementsByTagName(\"TD\")[n];\n")
  file.write("      y = rows[i + 1].getElementsByTagName(\"TD\")[n];\n")
  file.write("      /*check if the two rows should switch place,\n")
  file.write("      based on the direction, asc or desc:*/\n")
  file.write("      if (dir == \"asc\") {\n")
  file.write("        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {\n")
  file.write("          //if so, mark as a switch and break the loop:\n")
  file.write("          shouldSwitch= true;\n")
  file.write("          break;\n")
  file.write("        }\n")
  file.write("      } else if (dir == \"desc\") {\n")
  file.write("        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {\n")
  file.write("          //if so, mark as a switch and break the loop:\n")
  file.write("          shouldSwitch= true;\n")
  file.write("          break;\n")
  file.write("        }\n")
  file.write("      }\n")
  file.write("    }\n")
  file.write("    if (shouldSwitch) {\n")
  file.write("      /*If a switch has been marked, make the switch\n")
  file.write("      and mark that a switch has been done:*/\n")
  file.write("      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);\n")
  file.write("      switching = true;\n")
  file.write("      //Each time a switch is done, increase this count by 1:\n")
  file.write("      switchcount ++;      \n")
  file.write("    } else {\n")
  file.write("      /*If no switching has been done AND the direction is \"asc\",\n")
  file.write("      set the direction to \"desc\" and run the while loop again.*/\n")
  file.write("      if (switchcount == 0 && dir == \"asc\") {\n")
  file.write("        dir = \"desc\";\n")
  file.write("        switching = true;\n")
  file.write("      }\n")
  file.write("    }\n")
  file.write("  }\n")
  file.write("}\n")
  file.write("</script>\n")
  file.write("<table border=1  id=\"myTable\">\n")
  file.write("\t<tr>\n")
  file.write("\t\t<th onclick=\"sortTable(0)\">#</th>\n")
  file.write("\t\t<th onclick=\"sortTable(1)\">код</th>\n")
  file.write("\t\t<th onclick=\"sortTable(2)\">адрес</th>\n")
  file.write("\t\t<th onclick=\"sortTable(3)\">цена</th> $\n")
  file.write("\t\t<th onclick=\"sortTable(4)\">stat</th>\n")
  file.write("\t\t<th onclick=\"sortTable(5)\">комнат</th>\n")
  file.write("\t\t<th onclick=\"sortTable(6)\">год постройки</th>\n")
  switcher = 7
  days.each do |day|
    file.write("\t\t<th onclick=\"sortTable(#{switcher})\">#{day}</th>\n")
    switcher += 1
  end
  flats.each_pair do |code, info|
    # file.write "checking flat #{code}"
    i += 1
    days_arr = []
    days.each do |day|
      if info['history'].keys.include? day
        days_arr += [info['history'][day]]
      else
        days_arr += ['-']
      end
    end
    file.write("\t<tr>\n")
    file.write("\t\t<td>#{i}\n")
    file.write("\t\t<td>#{code}\n")
    file.write("\t\t<td><a href='http://www.t-s.by/buy/flats/#{code}/'"\
         " >#{info['address']}</a>\n")
    status_char = ''
    if info['status'] == 'down'
      status_char = "<span style=\"color:green\">&#8601;</span>"
    elsif info['status'] == 'up'
      status_char = "<span style=\"color:red\">&#8598;</span>"
    elsif info['status'] == 'new'
      status_char = "<span style=\"color:yellow\">&#8687;</span>"
    elsif info['status'] == 'sold'
      status_char = "<span style=\"color:blue\">&#8364;</span>"
    else
      status_char = '&nbsp;'
    end
    file.write("\t\t<td>#{info['price']}$\n")
    file.write("\t\t<td>#{status_char}\n")
    file.write("\t\t<td>#{info['rooms']}\n")
    file.write("\t\t<td>#{info['year']}\n")
    days_arr.each { |day| file.write("\t\t<td>#{day}\n") }
  end
  file.write("</table>\n")
  file.write("</body>\n")
  file.write("<html>\n")
  file.close()
end

def render(flats, days)
  i = 0
  head = '|%3s|%8s|%50s|%10s $|%6s|%6s|'
  table = '|%3d|%8d|%50s|%10d $|%6s|%6d|'
  days.each do
    head += '%12s|'
    table += '%12s|'
  end
  head += '\n'
  table += '\n'
  printf(head, '#', 'code', 'Address', 'Price', 'Rooms', 'Year', *days)
  flats.each_pair do |code, info|
    i += 1
    days_arr = []
    days.each do |day|
      if info['history'].keys.include? day
        days_arr += [info['history'][day]]
      else
        days_arr += [' ']
      end
    end
    printf(table, i, code, info['address'], info['price'],
           info['rooms'], info['year'], *days_arr)
  end
end

# con = Mysql2::Client.new(host: 'localhost', username: 'flat',
#                          password: 'flat', database: 'flats')
connection = JSONConnector.new('1.json')

flats = connection.get_all_flats
dates = connection.get_dates
# puts "Dates are: #{ dates }"
input_array = ARGV
if input_array.size > 0
  input_array.each do |output_file|
    render_html(flats, dates, output_file)
  end
else
  render_html(flats, dates)
end





