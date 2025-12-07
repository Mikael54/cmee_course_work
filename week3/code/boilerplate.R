# Author: Mikael Minten
# Date: October 2025
# Script: Basic_io.R
# Description: A simple boilerplate function.  

MyFunction <- function(Arg1, Arg2) {
    print(paste("argument", as.character(Arg1), "is a", class(Arg1)))
    print(paste("argument", as.character(Arg2), "is a", class(Arg2)))

    return(c(Arg1, Arg2))
}

MyFunction(1,2)
MyFunction("Riki","Tiki") #A different test