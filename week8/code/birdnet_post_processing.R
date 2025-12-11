# Clear your global environment 
rm(list = ls()) 

#load packages
library(dplyr) 
library(stringr) 
library(lubridate) 

library(ggplot2) 
library(tidyr)
library(vegan) #Contains diversity calculation functions 

library(knitr) 
library(readr)



Monkswood <- read.csv("../results/BirdNET_Monkswood.csv") 
Parsonage <- read.csv("../results/BirdNET_Parsonage.csv") 

# Add a new column to each data frame indicating the site so we have an identifier when we combine them 
Monkswood$Site <- "Monkswood" 
Parsonage$Site <- "Parsonage"

# Lets subset the data to remove the na's and to only look at calls with a confidence above 0.7
# for the first site
Monkswood_na <- Monkswood %>% drop_na()
Monkswood_subset <- subset(Monkswood_na, Monkswood_na$confidence>0.7) 

# for the second site
Parsonage_na <- Parsonage %>% drop_na()
Parsonage_subset <- subset(Parsonage_na, Parsonage_na$confidence>0.7) 


#bind both dfs together by rows to combine
Bird_combined <- rbind(Monkswood_subset, Parsonage_subset)

#Extract the time from the file name in r by 
Bird_combined$Time<-sub('.*_', '', Bird_combined$file)#removing everything before the _
Bird_combined$Time<-gsub("\\..*","", Bird_combined$Time)#everything after the .
Bird_combined$Time<-gsub('.{2}$', '', Bird_combined$Time)#then we remove the seconds

#Calculate number of calls per species per site
Species_names<-Bird_combined %>%
  group_by(Site) %>%
  count(common_name, sort=TRUE)

#Now lets plot and compare species
ggplot(Species_names, aes(fill=Site, y=n, x=reorder(common_name, n))) + 
  geom_bar(position="stack", stat="identity")+
  coord_flip() +# Changes the axes
  labs(y = "Frequency")+
  labs(x = "Species")







  # Lets compare the overlap of species at both sites 
# Get the names of all birds recorded from the sample 
Monkswood_species<- unique(Monkswood_subset$common_name)
Parsonage_species<- unique(Parsonage_subset$common_name)

#Comparing overlap between sites using the unique species above  
species_overlap <- intersect(Monkswood_species, Parsonage_species) 

# Find species unique to each site 
species_only_Monkswood <- setdiff(Monkswood_species, Parsonage_species)  
species_only_Parsonage <- setdiff(Parsonage_species, Monkswood_species) 

# Final values 
# Total number of species over both sites: output shows 31 species
total_species <- length(unique(c(Parsonage_species, Monkswood_species))) #output shows 31 species

# Number of overlapping species between sites: 
num_overlap <- length(species_overlap) # there are only 4 in common

# Number of unique species belonging to each site 
num_only_Monkswood <- length(species_only_Monkswood) #16 species unique
num_only_Parsonage <- length(species_only_Parsonage) #11 species unique

# We can now display this in a presence-absence figure using ggplot 
# Create a presence-absence data frame: 
presence_absence <- data.frame( species = unique(c(Monkswood_species, Parsonage_species))) %>% 
  mutate(Monkswood = species %in% Monkswood_species, 
         Parsonage = species %in% Parsonage_species) %>% 
  pivot_longer(cols = c(Monkswood, Parsonage), names_to = "Site", 
               values_to = "Present")


# Create the plot, where green is present and red is absent 
ggplot(presence_absence, aes(x = Site, y = species, fill = Present)) + 
  geom_tile(color = "white") + 
  scale_fill_manual(values = c("red3", "limegreen")) + 
  theme_classic() + 
  theme(axis.text.y = element_text(size = 6), 
        axis.text.x = element_text(angle = 0, hjust = 0.5, size = 12), 
        legend.position = "none", panel.grid = element_blank()) + 
  labs(x = "Site", y = "Species") + 
  theme(axis.title = element_text(size = 14), 
        strip.text = element_text(size = 12))







#Now lets look at diversity in each site

#Function to calculate Shannon Diversity Index 
shannon_diversity <- function(x) 
{ diversity(x, index = "shannon") 
}

# Calculate the diversity metrics for each site 
Monkswood_diversity <- Monkswood_subset %>% 
  summarize(Site = "Monkswood", 
            Species_Richness = n_distinct(common_name), #Finds the number of unique names 
            Shannon_Diversity = shannon_diversity(table(common_name)) 
            )

Parsonage_diversity <- Parsonage_subset %>% 
  summarize(Site = "Parsonage", 
            Species_Richness = n_distinct(common_name), #Finds the number of unique names 
            Shannon_Diversity = shannon_diversity(table(common_name)) 
  )

# Combine the results into a table 
diversity_table <- bind_rows(Monkswood_diversity, Parsonage_diversity) 
print(diversity_table)




#Lets look at some temporal trends
# Calculate the activity of each species at each site for each hour of the day 
activity_data <- Bird_combined %>% 
  group_by(Site, Time) %>% #Groups by site, species and time 
  summarise(activity = n(), .groups = 'drop') #Calculates 'activity'


# Create the activity plots for both sites 
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

Activity<- ggplot(activity_data, aes(x = Time, y = activity, colour=Site, group=Site)) + 
  geom_point() +
  geom_smooth() +
  scale_x_discrete(breaks=c("0545","0645","0745", "0845", "0930"))+
  labs(y = "Activity")+
  labs(x = "Time")+
  theme_new()
Activity