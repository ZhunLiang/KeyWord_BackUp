from optparse import OptionParser

parser = OptionParser()
parser.add_option("-l", dest = "left_gro", default = "tempLeft.gro", help = "input left gro file, default tempLeft.gro")
parser.add_option("-r", dest = "right_gro", default = "tempRight.gro", help = "input right gro file, default tempRight.gro")
parser.add_option("-n", dest = "new_gro_name", default = "Total_ele", help = "output gro system name, default Total_ele")
parser.add_option("-x", dest = "Box_X", default = "5", help = "output gro box size X")
parser.add_option("-y", dest = "Box_Y", default = "5", help = "output gro box size Y")
parser.add_option("-z", dest = "Box_Z", default = "8", help = "output gro box size Z")
parser.add_option("-o", dest = "output_gro", default = "Total.gro", help = "output gro file name, default Total.gro")
(options, args) = parser.parse_args()
left_gro = options.left_gro
right_gro = options.right_gro
new_gro_name = options.new_gro_name
output_gro = options.output_gro
X = options.Box_X
Y = options.Box_Y
Z = options.Box_Z
#left_gro="TI3C2-1.gro"
#right_gro="TI3C2-2.gro"
#new_gro_name = "Ti3C2-ele"
#output_gro = "Total.gro"
#X = str(5)
#Y = str(5)
#Z = str(5)
left_file = open(left_gro,'r')
right_file = open(right_gro,'r')
output_file = open(output_gro,"w")
left_line = left_file.readlines()
right_line = right_file.readlines()
left_number = int(left_line[1])
right_number = int(right_line[1])
total_number = left_number + right_number
total_line_number = len(left_line) + right_number
Box_Size = ("\t" + X +"\t" + Y + "\t" + Z + "\n")
for i in range(total_line_number):
    if i == 0:
        output_file.write(new_gro_name+'\n')
    elif i == 1:
        output_file.write(str(total_number) + '\n')
    elif i == total_line_number:
        output_file.write(left_line[-1] + '\n')
    elif i <= (left_number+1):
        output_file.write(left_line[i])
    elif i == total_line_number-1:
        output_file.write(Box_Size)
    else:
        output_file.write(right_line[i-left_number])
output_file.close()
left_file.close()
right_file.close()
