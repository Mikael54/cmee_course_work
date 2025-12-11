# Load the mammals data
# Load the per station data EVI data
# combine the data
# make the species prescence absence per day
# include code to make all empty days have value of 0
# run a glmer model to test for effect of EVI on presence absence of muntjac
# include day as a random effect


# clear working directory
rm(list = ls())

library(tidyverse)
library(lme4)

# Load data
mammals <- read_csv("../results/mammals_data.csv")
evi <- read_csv("../results/sensor_evi_silwood.csv")


# summary of data
# SD, mean, and range of EVI
evi_summary <- evi %>%
  summarise(
    mean = mean(EVI_Silwood, na.rm = TRUE),
    sd = sd(EVI_Silwood, na.rm = TRUE),
    min = min(EVI_Silwood, na.rm = TRUE),
    max = max(EVI_Silwood, na.rm = TRUE)
  )


str(mammals)
summary(as.factor(mammals$site))

str(evi)

names(mammals) <- tolower(names(mammals))

# Create grid column from site
mammals <- mammals %>%
  mutate(grid = case_when(
    site == "sp_table_camera_02_97_2025" ~ "97",
    site == "sp_table_camera_80_8_2025" ~ "80",
    site == "sp_table_camera_03_85_2025" ~ "85",
    site == "sp_table_camera_04_68_2025" ~ "68",
    site == "sp_table_camera_05_16_2025" ~ "16",
    site == "sp_table_camera_07_45_2025" ~ "45",
    site == "sp_table_camera_12_60_2025" ~ "60",
    site == "sp_table_camera_13_108_2025" ~ "108",
    site == "sp_table_camera_15_49_2025" ~ "49",
    site == "sp_table_camera_30_13_2025" ~ "13",
    site == "sp_table_camera_31_18_2025" ~ "18",
    TRUE ~ NA_character_
  ))

# Combine data
combined <- mammals %>%
  left_join(evi, by = c("grid"))

# Create presence/absence for muntjac per day
muntjac <- combined %>%
  filter(species == "muntiacus_reevesi") %>%
  group_by(grid, date) %>%
  summarise(presence = 1, .groups = "drop")





#create all dates
all_dates <- seq(as.Date("2025-10-08"), 
                 as.Date("2025-11-24"), 
                 by = "day")

all_grids <- unique(combined$grid[!is.na(combined$grid)])

all_combos <- expand_grid(grid = all_grids, date = all_dates) %>%
  left_join(evi, by = "grid")

# Add zeros for absent days
muntjac_full <- all_combos %>%
  left_join(muntjac, by = c("grid", "date")) %>%
  mutate(presence = ifelse(is.na(presence), 0, presence)) %>%
  filter(!is.na(EVI_Silwood)) %>%  # Remove rows with missing EVI
  mutate(scaled = scale(EVI_Silwood))



summary(as.factor(muntjac_full$presence))


# Run GLMER model
model <- glmer(presence ~ EVI_Silwood + 
               # (1|date) +
                (1|grid), 
               data = muntjac_full, 
               family = binomial)


# Chance increase per unit EVI
cat("\nChance increase per unit EVI:", exp(fixef(model)[2]), "\n")

cat("\nBase chance at 0 EVI:", exp(fixef(model)[1]), "\n")


# View results
summary(model)

anova(model, test="Chisq")


library(ggeffects)

predictions <- ggpredict(model, terms = "EVI_Silwood [all]")

flip_point <- -fixef(model)[1] / fixef(model)[2]
cat("\nFlip point (EVI at 50% probability):", flip_point, "\n")


# Plot with ggplot
plot<- ggplot(predictions, aes(x = x, y = predicted)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2) +
  geom_line(size = 1) +
  geom_point(data = muntjac_full, 
             aes(x = EVI_Silwood, y = presence), 
             alpha = 0.1, size = 2,
             # add vertical jitter to points
             position = position_jitter(height = 0.05, width = 0)
             ) +
  geom_vline(xintercept = flip_point, linetype = "dashed") +
  annotate("text", x = flip_point, y = 0.8, 
           label = "Flip point", angle = 90, vjust = -0.5) +
  labs(x = "\nEVI", 
       y = "Probability of Muntjac Presence\n") +
       theme_bw() +
       theme(
         axis.text.x = element_text(size = 12),     # making the years at a bit of an angle
         axis.text.y = element_text(size = 12),
         axis.title = element_text(size = 14, face = "plain"),                        
         panel.grid = element_blank(),                                   # Removing the background grid lines               
         plot.margin = unit(c(1,1,1,1), units = "cm"),                 # Adding a 1cm margin around the plot
)                                 

ggsave(
  filename = "../results/output_1.pdf",
  plot = plot,
  device = "pdf",
  width = 8,    # optional
  height = 6    # optional
)

system("evince ../results/output.pdf &")
  


# using the model to calculate
# R2 (or speudo/marginal R2)
# flip point
# dispersion parameters
# assumption (if possible)- homogeneity of variance, Q-Q plots (any other diagnostic plots?)
# outliers
# anything else?


# ---- MODEL DIAGNOSTICS ----

# 1. R-squared (marginal and conditional)
library(performance)
r2 <- r2_nakagawa(model)
print(r2)

# 2. Flip point (EVI value where probability = 0.5)
flip_point <- -fixef(model)[1] / fixef(model)[2]
cat("\nFlip point (EVI at 50% probability):", flip_point, "\n")

# 3. Dispersion parameter
library(DHARMa)
sim_resid <- simulateResiduals(model, n = 1000)
testDispersion(sim_resid)

# calculateing overdispersion manually
overdisp_fun <- function(model) {
    rdf <- df.residual(model)
    rp  <- residuals(model, type = "pearson")
    Pearson.chisq <- sum(rp^2)
    ratio <- Pearson.chisq / rdf
    p <- pchisq(Pearson.chisq, rdf, lower.tail = FALSE)
    c(c.hat = ratio, p.value = p)
}

overdisp_fun(model)




# 4. Diagnostic plots
par(mfrow = c(2, 2))

# DHARMa residual plots
plot(sim_resid, title = "DHARMa Residual Diagnostics")

# Q-Q plot
testQuantiles(sim_resid)

# Outliers test
testOutliers(sim_resid)

# Reset plot window
par(mfrow = c(1, 1))

# 5. Additional diagnostics
# Check for influential observations
library(influence.ME)
infl <- influence(model, obs = TRUE)

# Get Cook's distances
cooks_d <- cooks.distance(infl)

influential <- which(cooks_d > 1)
if(length(influential) > 0) {
  cat("\nInfluential observations (Cook's D > 1):\n")
  print(data.frame(
    Observation = influential,
    Cooks_D = cooks_d[influential],
    grid = muntjac_full$grid[influential],
    Date = muntjac_full$Date[influential],
    EVI = muntjac_full$EVI_Silwood[influential],
    presence = muntjac_full$presence[influential]
  ))
} else {
  cat("\nNo observations with Cook's D > 1\n")
}



# Residual variance:


# extract fixed-effect linear predictor (no random effects)
eta_fixed <- predict(model, re.form = NA, type = "link")  # link-scale predictions from fixed effects only
V_f <- var(eta_fixed)                                    # variance of fixed-effect linear predictor

# random intercept variance
Var_random <- as.numeric(VarCorr(model)$grid[1])        # or inspect VarCorr(model)

# residual variance on logit scale
Var_resid <- (pi^2) / 3

# totals and R2
V_total <- V_f + Var_random + Var_resid
R2_m <- V_f / V_total
R2_c <- (V_f + Var_random) / V_total
R2_random_share <- Var_random / V_total   # equals R2_c - R2_m