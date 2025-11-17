# Author: Mikael Minten
# Date: October 2025
# Description: This script loads predator-prey data, performs log-log
# regression, analyzes results by Lifestage, and saves the plot and results table.


library(tidyverse)

ecol <- read.csv("../data/ecol_archives_e089_51_d1.csv")

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


regression_results <- ecol %>%
  group_by(Type.of.feeding.interaction, Predator.lifestage) %>%
  filter(n() >= 3) %>% # make sure that there are no NaNs
  summarise(
    # Fit the linear model
    model = list(lm(Prey.mass.grams ~ Predator.mass, data = cur_data())),
    
    # Extract slope, intercept, and summary stats
    slope = coef(model[[1]])[2],
    intercept = coef(model[[1]])[1],
    r_squared = summary(model[[1]])$r.squared,
    f_statistic = summary(model[[1]])$fstatistic[1],
    p_value = pf(summary(model[[1]])$fstatistic[1],
                 summary(model[[1]])$fstatistic[2],
                 summary(model[[1]])$fstatistic[3],
                 lower.tail = FALSE),
    .groups = "drop"
  ) %>%
  select(-model)  # remove model list column before saving


write.csv(regression_results, "../results/reggression_results.csv")

ggsave("../results/reggression.pdf", plot = p, width = 8, height = 15)
