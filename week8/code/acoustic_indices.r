rm(list = ls()) #clears environment

library(tuneR) # For reading audio files 
library(soundecology) # For audio analysis functions 
library(seewave) # Another package for audio analysis functions 
library(dplyr) # To manipulation data 
library(ggplot2) # For plotting results 
library(tidyr) # For changing the shape of the datasets 
library(patchwork) # For combining plots
library(reshape2) #to change data from long to wide and visa versa
library(stringr) # For combining plots

# Set the path to your folder containing the audio files for one site
setwd("../sandbox/Monkswood_dawn") 

# List all the WAV files in the directory 
audio_directory <- "../sandbox/Monkswood_dawn" 

# This creates a list of all the audio files (with .wav extension) in the specified folder 
file_list <- list.files(pattern = "\\.wav$", full.names = TRUE) 

# Create empty lists to store the acoustic indices for each file 
# These lists will hold the results of the analysis for each file in the folder 
aci_scores <- numeric(length(file_list)) # For ACI scores 
ndsi_scores <- numeric(length(file_list)) # For NDSI scores 
bi_scores <- numeric(length(file_list)) # For BI scores 

# Loop through each file in the folder 
for (i in seq_along(file_list)) { 
  # Read the current audio files using the readWave function from tuneR package
  file <- readWave(file_list[i]) 
  
# Calculate the Acoustic Complexity Index (ACI) 
  # calculates the ACI score for a the list of files and stores the result in a variable named aci_value
  aci_value <- acoustic_complexity(file, min_freq = 1000, max_freq = 11000)
  #store each calculated aci_value into a list called aci_scores
  aci_scores[i] <- aci_value 
  aci_scores
  
  # Calculate the NDSI 
  ndsi_value <- ndsi(file) 
  ndsi_scores[i] <- ndsi_value 
  ndsi_scores
  
  # Calculate the Bioacoustic index (Bi) 
  bi_value <- bioacoustic_index(file, min_freq = 1000, max_freq = 11000) 
  bi_scores[i] <- bi_value  
  bi_scores
}



# Converting each list into a vector, so that they can be combined into a single data frame. 
aci_vector <- unlist(aci_scores) 
ndsi_vector <- unlist(ndsi_scores) 
bi_vector <- unlist(bi_scores) 

#extract the date and time from the file name
Date_Time<-list.files(full.names = FALSE)

#convert to a date and time class
Date_Time<-as.POSIXct(Date_Time, format = '%Y%m%d_%H%M%S.wav', tz = 'UTC')

#check structure to make sure its in date format
str(Date_Time)





# Combine the vectors into a data frame
# This data frame contains the corresponding index scores for each file
# the first is the name of the column and the second is the vector name, e.g., ACI_score = aci_vector
indice_data <- data.frame(ACI_score = aci_vector, 
NDSI_score = ndsi_vector, BI_score = bi_vector, Date_Time=Date_Time) 

#extract hour and date into separate columns
# Extract the date component
indice_data$date <- as.Date(indice_data$Date_Time)

#check structure to make sure its in date format
str(indice_data$date)





# 

# Extract time component
indice_data$time <- format(indice_data$Date_Time, format = "%H:%M")


#Now lets plot the indices
#First load a custom theme- you can add your own if you prefer
theme_new <- function(base_size = 17, base_family = "Helvetica"){
  theme_classic(base_size = base_size, base_family = base_family) %+replace%
    theme(
      #line = element_line(colour="black"),
      #text = element_text(colour="black"),
      axis.text.x=element_text(colour = "black", size=17),
      axis.text.y=element_text(colour = "black", size=17),
      axis.title=element_text(size=21,face="bold"),
      legend.position = 'top', legend.direction = "horizontal",
      #strip.text = element_text(size=21),
      axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
      legend.key=element_rect(colour=NA, fill =NA),
      panel.grid = element_blank(),   
      #panel.border = element_rect(fill = NA, colour = "black", size=0),
      #panel.background = element_rect(fill = "white", colour = "black"), 
      #strip.background = element_rect(fill = NA)
    )
}

#Plot ACI
ACI<-ggplot(indice_data, aes(x=time)) + 
  geom_line(aes(y = ACI_score , group = 1), color = "red")+ #tells ggplot to treat all x axis values as 1
  scale_x_discrete(breaks=c("05:45","06:45","07:45", "08:45", "09:45"))+
  labs(y = "ACI")+
  labs(x = "Time")+
theme_new()

#Plot NDSI 
NDSI<-ggplot(indice_data, aes(x=time)) + 
  geom_line(aes(y = NDSI_score , group = 1), color = "green")+ #tells ggplot to treat all x axis values as 1
  scale_x_discrete(breaks=c("05:45","06:45","07:45", "08:45", "09:45"))+
  labs(y = "NDSI")+
  labs(x = "Time")+
  theme_new()

#Plot BI
BI<-ggplot(indice_data, aes(x=time)) + 
  geom_line(aes(y = BI_score , group = 1), color = "blue")+ #tells ggplot to treat all x axis values as 1
  scale_x_discrete(breaks=c("05:45","06:45","07:45", "08:45", "09:45"))+
  labs(y = "BI")+
  labs(x = "Time")+
  theme_new()

# Combine the three plots vertically 
combined_plot <- ACI / BI / NDSI 
# Display the combined plot 





# Now lets run the 2nd site
# Set the path to your folder containing the audio files for one site
setwd("../Parsonage_dawn") 

# This creates a list of all the audio files (with .wav extension) in the specified folder 
file_list2 <- list.files(pattern = "\\.wav$", full.names = TRUE) 

# Create empty lists to store the acoustic indices for each file 
# These lists will hold the results of the analysis for each file in the folder 
aci_scores2 <- numeric(length(file_list2)) # For ACI scores 
ndsi_scores2 <- numeric(length(file_list2)) # For NDSI scores 
bi_scores2 <- numeric(length(file_list2)) # For BI scores 

# Loop through each file in the folder 
for (i in seq_along(file_list2)) { 
  # Read the current audio files using the readWave function from tuneR package
  file <- readWave(file_list2[i]) 
  
  # Calculate the Acoustic Complexity Index (ACI) 
  # calculates the ACI score for a the list of files and stores the result in a variable named aci_value
  aci_value2 <- acoustic_complexity(file, min_freq = 1000, max_freq = 11000)
  #store each calculated aci_value into a list called aci_scores
  aci_scores2[i] <- aci_value2
  aci_scores2
  
  # Calculate the NDSI 
  ndsi_value2 <- ndsi(file) 
  ndsi_scores2[i] <- ndsi_value2 
  ndsi_scores2
  
  # Calculate the Bioacoustic index (Bi) 
  bi_value2 <- bioacoustic_index(file, min_freq = 1000, max_freq = 11000) 
  bi_scores2[i] <- bi_value2  
  bi_scores2
}




# Converting each list into a vector, so that they can be combined into a single data frame. 
aci_vector2 <- unlist(aci_scores2) 
ndsi_vector2 <- unlist(ndsi_scores2) 
bi_vector2 <- unlist(bi_scores2) 

#extract the date and time from the file name
Date_Time2<-list.files("C:/Imperial acoustics course/Parsonage_dawn", full.names = FALSE)

#convert to a date and time class
Date_Time2<-as.POSIXct(Date_Time2, format = '%Y%m%d_%H%M%S.wav', tz = 'UTC')

#check structure to make sure its in date format
str(Date_Time2)


# Combine the vectors into a data frame
# This data frame contains the corresponding index scores for each file
# the first is the name of the column and the second is the vector name, e.g., ACI_score = aci_vector
indice_data2 <- data.frame(ACI_score = aci_vector2, 
                          NDSI_score = ndsi_vector2, BI_score = bi_vector2, Date_Time2=Date_Time2) 

#extract hour and date into separate columns
# Extract the date component
indice_data2$date <- as.Date(indice_data2$Date_Time2)

#check structure to make sure its in date format
str(indice_data2$date2)


# Extract time component
indice_data2$time <- format(indice_data2$Date_Time2, format = "%H:%M")


# Add a new column to each data frame indicating the site 
indice_data$Site <- "Monkswood" 
indice_data2$Site <- "Parsonage"

#Create df's for ACI by subsetting aci columns
ACI_Monkswood <- subset(indice_data, select = c(ACI_score, date, time, Site))
ACI_Parsonage <- subset(indice_data2, select = c(ACI_score, date, time, Site))

#bind both df's together by rows
ACI_combined <- rbind(ACI_Monkswood, ACI_Parsonage )

#Now plot both sites for comparison
ggplot(ACI_combined, aes(x = time, y = ACI_score, colour=Site, group=Site)) + 
  geom_line() + 
  scale_x_discrete(breaks=c("05:45","06:45","07:45", "08:45", "09:45"))+
  labs(y = "ACI")+
  labs(x = "Time")+
  theme_new()




  #Create df's for NDSI by subsetting NDSI columns
NDSI_Monkswood <- subset(indice_data, select = c(NDSI_score, date, time, Site))
NDSI_Parsonage <- subset(indice_data2, select = c(NDSI_score, date, time, Site))

#bind both df's together by rows
NDSI_combined <- rbind(NDSI_Monkswood, NDSI_Parsonage )

#Now plot both sites for comparison
ggplot(NDSI_combined, aes(x = time, y = NDSI_score, colour=Site, group=Site)) + 
  geom_line() + 
  scale_x_discrete(breaks=c("05:45","06:45","07:45", "08:45", "09:45"))+
  labs(y = "NDSI")+
  labs(x = "Time")+
  theme_new()





  #Create df's for NDSI by subsetting NDSI columns
BI_Monkswood <- subset(indice_data, select = c(BI_score, date, time, Site))
BI_Parsonage <- subset(indice_data2, select = c(BI_score, date, time, Site))

#bind both df's together by rows
BI_combined <- rbind(BI_Monkswood, BI_Parsonage )

#Now plot both sites for comparison
ggplot(BI_combined, aes(x = time, y = BI_score, colour=Site, group=Site)) + 
  geom_line() + 
  scale_x_discrete(breaks=c("05:45","06:45","07:45", "08:45", "09:45"))+
  labs(y = "BI")+
  labs(x = "Time")+
  theme_new()




  # Create a boxplot comparing ACI distributions between the two sites 
aci_boxplot_comparison <- 
  ggplot(data = ACI_combined, aes(x = Site, y = ACI_score)) + 
  geom_boxplot() + # Boxplot to show distribution 
  theme_new() + 
  labs(title = "", x = "Site", y = "ACI Score") 
aci_boxplot_comparison




#Lets remove the outlier as this appears to be one file, here we are removing values over 900
ACI_combined_subset  <- ACI_combined[ACI_combined$ACI_score <= 900, ]

aci_boxplot_comparison <- 
  ggplot(data = ACI_combined_subset, aes(x = Site, y = ACI_score)) + 
  geom_boxplot() + # Boxplot to show distribution 
  theme_new() + 
  labs(title = "", x = "Site", y = "ACI Score") 
aci_boxplot_comparison




# Create a boxplot comparing BI distributions between the two sites 
bi_boxplot_comparison <- 
  ggplot(data = BI_combined, aes(x = Site, y = BI_score)) + 
  geom_boxplot() + # Boxplot to show distribution 
  theme_new() + 
  labs(title = "", x = "Site", y = "BI Score") 
bi_boxplot_comparison




# Create a boxplot comparing NDSI distributions between the two sites 
ndsi_boxplot_comparison <- 
  ggplot(data = NDSI_combined, aes(x = Site, y = NDSI_score)) + 
  geom_boxplot() + # Boxplot to show distribution 
  theme_new() + 
  labs(title = "", x = "Site", y = "NDSI Score") 
ndsi_boxplot_comparison



# Now lets run some statistical tests to see if there is a difference between sites
# we will run a t-test as we are comparing categorical predictors
# if p is less than 0.05 we can say there is a significant difference between the means
ACI_test_result <- t.test(ACI_score ~ Site, data = ACI_combined_subset) 
ACI_test_result



BI_test_result <- t.test(BI_score ~ Site, data = BI_combined) 
BI_test_result



NDSI_test_result <- t.test(NDSI_score ~ Site, data = NDSI_combined) 
NDSI_test_result