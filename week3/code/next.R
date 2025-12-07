# Author: Mikael Minten
# Date: October 2025
# Script: control_flow.R
# Description: demonstrates the next tool.  


for (i in 1:10) {
  if ((i %% 2) == 0) # check if the number is odd
    next # pass to next iteration of loop 
  print(i)
}


