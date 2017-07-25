These code can build a channel model
Need to prepare file:
    1. A unit gro of wall(electrode .gro file).
    2. Bulk equilibrated model(.gro file) and the corresponding .top file.
    3. scale-nvt.mdp. Run scale mdp file.(It should has short steps and NVT run). Do not change the name.
    4. tune_npt.mdp. Run tune bulk mdp file. (It should has short steps and NPT run). Do not change the name.
    5. Parameter file. Not realized right now. The parameter now defined in the main.sh file top. You should set your own parameter at there.
    6. Other perl file and python file. The python file right now are use in ~/bin/, latter it will be change so you can defined.

The next are the introduce about the code file:
    Python
         1.CombineGro.py
              This code used to combine two gro file together. Use "python CombineGro.py -h" to get the help
         2.DelMole.py
              This code used to deleted !ion pair! number by your defined. Like above to get the help, the next python code is the same. 
         3.GetZmax.py
              Get the z coordinate max and min value by your given gro file. 
         4.SortMole.py
              Sort the gro file. Used to sort the "genconf -f start.gro-nbox x y z -o end.gro". When there are two type molecular in the start.gro, this code can sort it.
    Perl
         1.main.sh
              Main code to realize the function
         2.tune_bulk.sh
              Delete the ion pair number by given bulk ion gro, and equilibrated at NPT run at short time(change the time in the tune_npt.mdp).
         3. scale_bulk.sh
              Scale the bulk ion gro, and run NVT.
         4. Ion_channel.sh
              Change the scaled gro file to be a channel shape so that we can copy the coordinate in electrode gro file.

##########!!!!!!!!!!   Here is the modification record     !!!!!!!!!############### 

