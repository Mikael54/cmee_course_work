

library(tidyverse)

ecol <- read.csv("../data/ecol_archives_e089_51_d1.csv")



# coulor = predator. lifestage
# facet = Type.of.feeding.interaction
# x= prey mass in grams, y= predator mass in grams
# include and lm function


# step 1- is make sure the units are consistem


gram_conversion <- function(unit, value) {
  ifelse(unit == "mg",
         value / 1000,
         ifelse(unit == "g",
                value,
                NA))
}

ecol <- ecol %>%
    mutate(Prey.mass.grams = gram_conversion(Prey.mass.unit, Prey.mass))



(p <- ggplot(ecol, aes(x=Prey.mass.grams, y = Predator.mass, colour = Predator.lifestage)) + 
    geom_point(shape = I(3)) + 
    facet_wrap(Type.of.feeding.interaction~., ncol =1, strip.position = "right") +
    geom_smooth(method = "lm", fullrange = TRUE) + 
    scale_x_log10() +                    # log10 x-axis
    scale_y_log10() +                    # log10 y-axis
    theme_bw() +
  theme(
    legend.position = "bottom",
    legend.title = element_text(face = "bold")   
  ) +
  guides(colour = guide_legend(nrow = 1)) +
  labs(
    x = "Prey Mass in grams",               
    y = "Predator Mass in grams"                 
  ))
# everything to be included: The regression results should include the following with appropriate headers (e.g., slope, intercept, etc, in each Feeding type
#life stage category): regression slope, regression intercept, R
#, F-statistic value, and p-value of the overall regression (Hint: Review the Stats week!).