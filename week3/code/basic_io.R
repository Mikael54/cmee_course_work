# A simple script to illustrate R input-output.  
# Run line by line and check inputs outputs to understand what is happening  

my_data <- read.csv("../data/trees.csv", header = TRUE) # import with headers

write.csv(my_data, "../results/my_data.csv") #write it out as a new file

write.table(my_data[1,], file = "../results/my_data.csv",append=TRUE) # Append to it

write.csv(my_data, "../results/my_data.csv", row.names=TRUE) # write row names

write.table(my_data, "../results/my_data.csv", col.names=FALSE) # ignore column names

