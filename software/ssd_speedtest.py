#!/usr/bin/python
 
import os, sys, mmap
 
# Open a file using O_direct
fdr = os.open( "testfile_redo", os.O_RDWR|os.O_CREAT|os.O_DIRECT )
fdi = os.open( "testfile_inno", os.O_RDWR|os.O_CREAT|os.O_DIRECT )

#create a mmap object of defined length to write 
#redopage dimension
r = mmap.mmap(-1, 512)

#innodb page dimension
m = mmap.mmap(-1, 16384)



#for a defined loop of X  
for i in range (1,1000):
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
