rm(list=ls())

library(tidyverse)

load("../data/key_west_annual_mean_temperature.RData")

# calculate p values
permutation <- function(df, number_of_permutation){
    cof_result <- vector(, number_of_permutation)
    for(i in 1:number_of_permutation) {
        cof_result[i]<- cor(df$Year, sample(df$Temp, nrow(df), replace = FALSE))
    }
    return(cof_result)
 }

calc_p_value <- function(sequential_cof, permutation_cof) {
    greater_than <- 0
    less_than <- 0
    for(i in 1:length(permutation_cof)) {
        if (permutation_cof[i] > sequential_cof) {
            greater_than <- greater_than + 1 
        } else { 
            less_than <- less_than + 1
        }
    }
    return(greater_than/less_than) 
}

sequential_cof <-cor(ats$Year, ats$Temp)

permutation_cof <- permutation(ats, 100000)

calc_p_value(sequential_cof, permutation_cof)



# Making a figure

(p <- ggplot(ats, aes(x = Year, y = Temp)) +
  geom_point(color = I("black"), size = I(2)) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", fullrange = TRUE) +
  labs(
    title = "Annual Temperature in Florida
    Between 1900 and 2000\n",
    x = "\nYear",
    y = "Temperature (°C)\n"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, 
                              margin = margin(b = 15)),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(20, 20, 20, 20)
  ))


# Exporting that figure

ggsave("../results/temperature_plot.pdf", 
       plot = p, 
       width = 8, 
       height = 6, 
       device = "pdf")


