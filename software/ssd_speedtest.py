#!/usr/bin/python3
# test
 
import os, sys, mmap, datetime
from argparse import ArgumentParser

parser = ArgumentParser(description='SSD test simple')
parser.add_argument("-l", "--loops", dest="loops",default=1000,type = int,
                    help="number of loops to execute")
args = vars(parser.parse_args())

loops = args['loops']

a = datetime.datetime.now()
 
# Open a file using O_direct
fdr = os.open( "testfile_redo", os.O_RDWR|os.O_CREAT|os.O_DIRECT )
fdi = os.open( "testfile_inno", os.O_RDWR|os.O_CREAT|os.O_DIRECT )

#create a mmap object of defined length to write 
#redopage dimension
r = mmap.mmap(-1, 512)

#innodb page dimension
m = mmap.mmap(-1, 16384)



#for a defined loop of X  
for i in range (1,loops):
   os.lseek(fdr,os.SEEK_SET,0)
   os.lseek(fdi,os.SEEK_SET,0)   
   r[1] = 1
   m[1] = 1
   os.write(fdr, r)
   os.write(fdi, m)
   os.fsync(fdr)
   os.fsync(fdi)   
 
# Close opened file
os.close( fdr )
os.close( fdi )
os.remove( "testfile_redo" )
os.remove( "testfile_inno" )
b = datetime.datetime.now()
print("Time taken: " + str(b-a))
