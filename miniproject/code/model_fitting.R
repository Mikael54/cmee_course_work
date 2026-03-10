# preamble


# ====================================================================
# region - Load libraries and data
# ====================================================================


require("ggplot2")
require("ggeffects")
require("tidyverse")
require("minpack.lm")
require("nls.multstart")
require("AICcmodavg")
require("zoo")
require("nlstools")
require("lme4")
require("lmerTest")
require("performance")
require("see")



# load the data
data_clean <- read.csv("../results/data_clean.csv", header = TRUE)


# endregion
# ====================================================================
# region - Define growth model functions
# ====================================================================

# create a linear model
linear_model <- function(t, a, b){
  a*t + b
}

# Baranyi model
baranyi_model <- function(t, r_max, N_max, N_0, t_lag){  # Baranyi model (Baranyi 1993)
  return(N_max + log10((-1+exp(r_max*t_lag) + exp(r_max*t))/(exp(r_max*t) - 1 + exp(r_max*t_lag) * 10^(N_max-N_0))))
}

# Buchanan model
buchanan_model <- function(t, r_max, N_max, N_0, t_lag){ # Buchanan model - three phase logistic (Buchanan 1997)
  return(N_0 + (t >= t_lag) * (t <= (t_lag + (N_max - N_0) * log(10)/r_max)) * r_max * (t - t_lag)/log(10) + (t >= t_lag) * (t > (t_lag + (N_max - N_0) * log(10)/r_max)) * (N_max - N_0))
}

# endregion
# ====================================================================
# region - step 3: extract the parameters
# ====================================================================

# more efficient function- replace lm() with direct calc
roll_regress <- function(x) {
  t <- x[, "t"]
  N <- x[, "N"]
  n <- length(t)

  t_mean <- mean(t)
  N_mean <- mean(N)
  
  ss_tt <- sum((t - t_mean)^2)
  ss_Nt <- sum((N - N_mean) * (t - t_mean))

  slope     <- if (ss_tt == 0) 0 else ss_Nt / ss_tt
  intercept <- N_mean - slope * t_mean
  
  ss_res <- sum((N - (intercept + slope * t))^2)
  ss_tot <- sum((N - N_mean)^2)
  rsq    <- if (ss_tot == 0) 0 else 1 - ss_res / ss_tot

  data.frame(slope = slope, intercept = intercept, rsq = rsq)
}

get_start_params <- function(group_data, num_points = 4) {
  # Assumes all values are already in log10 scale
  N <- group_data$log10_popbio
  t <- group_data$time

  # Sort by time
  ord <- order(t)
  N   <- N[ord]
  t   <- t[ord]

  N_0_start   <- min(N, na.rm = TRUE)
  N_max_start <- max(N, na.rm = TRUE)

  # r_max via rolling regression
  win_mat <- cbind(N = N, t = t)

  slopes <- tryCatch({
    rolls <- zoo::rollapplyr(
      win_mat,
      width     = num_points,
      FUN       = roll_regress,
      by.column = FALSE,
      fill      = NA,
      align     = "center"
    )
    as.numeric(rolls[, "slope"])
  }, error = function(e) {
    # Fallback: simple finite difference
    dt <- diff(t)
    dt[dt == 0] <- NA
    rep(max(diff(N) / dt, na.rm = TRUE), length(N))
  })

  r_max_start <- max(slopes, na.rm = TRUE)

  # Guard: r_max must be positive and finite; fallback to finite difference
  if (!is.finite(r_max_start) || r_max_start <= 0) {
    dt <- diff(t)
    dt[dt == 0] <- NA
    r_max_start <- max(diff(N) / dt, na.rm = TRUE)
  }

  # t lag via rolling regression
  best_idx  <- which.max(slopes)
  if (length(best_idx) > 0) {
    start_idx   <- max(1, best_idx - floor(num_points / 2))
    t_lag_start <- t[start_idx]
  } else {
    dN  <- diff(N)
    ddN <- diff(dN)
    t_lag_start <- if (length(ddN) >= 1) t[which.max(ddN)] else t[1]
  }

  list(
    N_0   = N_0_start,
    N_max = N_max_start,
    t_lag = t_lag_start,
    r_max = r_max_start
  )
}


get_start_params_simple <- function(group_data, log_scale = TRUE) {
  # Use log10 population if model is in log space (Gompertz, Baranyi, Buchanan)
  # Use raw popbio if model is in linear space (Logistic, Cubic)
  
  if (log_scale) {
    N    <- group_data$log10_popbio
    t    <- group_data$time
  } else {
    N    <- group_data$popbio
    t    <- group_data$time
  }
  
  # Sort by time to ensure diff() is meaningful
  ord  <- order(t)
  N    <- N[ord]
  t    <- t[ord]
  
  N_0_start   <- min(N, na.rm = TRUE)
  N_max_start <- max(N, na.rm = TRUE)
  
  # t_lag: time at maximum curvature (inflection of first derivative)
  # Guard against edge cases where diff is length < 2
  dN   <- diff(N)
  ddN  <- diff(dN)
  t_lag_start <- if (length(ddN) >= 1) t[which.max(ddN)] else t[1]
  
  # r_max: max instantaneous rate (per unit time)
  dt        <- diff(t)
  dt[dt == 0] <- NA                          # avoid division by zero
  r_max_start <- max(dN / dt, na.rm = TRUE)
  
  list(
    N_0    = N_0_start,
    N_max  = N_max_start,
    t_lag  = t_lag_start,
    r_max  = r_max_start
  )
}

# endregion
# ====================================================================
# region - Step 4: Run the growth models on multistart with NLSLM 
# ====================================================================

run_growth_models_multistart <- function(data,
                                         model_fn,
                                         model_name,
                                         group_var  = "id_num",
                                         n_iter     = 1500,
                                         conv_count = 100,
                                         max_iter   = 1500,
                                         N0_upper = 2,
                                         Nmax_upper = 2,
                                         tlag_upper = 20,
                                         r_max_upper = 50
                                         ) {
  groups <- unique(data[[group_var]])
  results <- lapply(groups, function(g) {
    group_data <- data[data[[group_var]] == g, ]
    fit_data   <- data.frame(t = group_data$time, y = group_data$log10_popbio)
    starts     <- get_start_params(group_data)
    params     <- names(formals(model_fn))[-1]
    start_list <- starts[params]

    start_upper_all <- list(
      N_0   = start_list$N_0   + N0_upper,
      N_max = start_list$N_max + Nmax_upper,
      t_lag = start_list$t_lag * tlag_upper,
      r_max = start_list$r_max * r_max_upper
    )
    start_lower_all <- list(
      N_0   =  0, 
      N_max =  start_list$N_0,
      r_max = 0,    
      t_lag = 0     
    )

    start_upper <- start_upper_all[params]
    start_lower <- start_lower_all[params]

    param_str <- paste(params, collapse = ", ")
    fmla      <- as.formula(paste0("y ~ model_fn(t, ", param_str, ")"))

    fit <- tryCatch(
      nls_multstart(fmla,
                    data              = fit_data,
                    iter              = n_iter,
                    start_lower       = start_lower,
                    start_upper       = start_upper,
                    convergence_count = conv_count,
                    control           = nls.lm.control(maxiter = max_iter)),
      error = function(e) {
        message(sprintf("[%s | group %s] failed: %s", model_name, g, e$message))
        NULL
      }
    )
    list(fit = fit, group = g, model = model_name)
  })
  names(results) <- as.character(groups)
  results
}

# Code for simple linear models (y = a + bx)
run_simple_linear_models <- function(data, model_name, group_var = "id_num") {
  
  groups  <- unique(data[[group_var]])
  results <- lapply(groups, function(g) {
    group_data <- data[data[[group_var]] == g, ]
    fit_data   <- data.frame(t = group_data$time, y = group_data$log10_popbio)
    fit <- tryCatch(
      lm(y ~ t, data = fit_data),
      error = function(e) {
        message(sprintf("[%s | group %s] failed: %s", model_name, g, e$message))
        NULL
      }
    )
    list(fit = fit, group = g, model = model_name)
  })
  names(results) <- as.character(groups)
  results
}
# endregion


# ====================================================================
# region - Step 5: Run model diagnostic
# ====================================================================

# diagnose fits function
diagnose_fits <- function(fit_list) {
  
  do.call(rbind, lapply(fit_list, function(x) {
    
    if (is.null(x$fit)) return(NULL)
    
    tryCatch({
      
      resid_obj <- nlsResiduals(x$fit)
      tests     <- test.nlsResiduals(resid_obj)
      
      p_shapiro <- tests$p.value[1]
      p_runs    <- tests$p.value[2]
      
      n_obs <- length(residuals(x$fit))
      n_par <- length(coef(x$fit))
      
      data.frame(
        group        = x$group,
        model        = x$model,
        n_obs        = n_obs,
        df           = n_obs - n_par,       # residual degrees of freedom
        p_shapiro    = p_shapiro,
        p_runs       = p_runs,
        pass_shapiro = p_shapiro > 0.05,
        pass_runs    = p_runs    > 0.05,
        pass_both    = p_shapiro > 0.05 & p_runs > 0.05
      )
      
    }, error = function(e) NULL)
  }))
}

# summarise_diagnostics function
summarise_diagnostics <- function(diag_df) {
  cat(sprintf("\nDiagnostics for model: %s\n", unique(diag_df$model)))
  cat(sprintf("  Total fits assessed : %d\n",  nrow(diag_df)))
  cat(sprintf("  Median n_obs        : %d\n",  median(diag_df$n_obs)))
  cat(sprintf("  Median df           : %d\n",  median(diag_df$df)))
  cat(sprintf("  Pass Shapiro-Wilk   : %d/%d\n", sum(diag_df$pass_shapiro), nrow(diag_df)))
  cat(sprintf("  Pass runs test      : %d/%d\n", sum(diag_df$pass_runs),    nrow(diag_df)))
  cat(sprintf("  Pass both tests     : %d/%d\n", sum(diag_df$pass_both),    nrow(diag_df)))
}


# endregion
# ====================================================================
# region - Step 6: Run model evaluation
# ====================================================================

# Helper function to collect AIC/AICc/BIC from a list of fit lists
collect_metrics <- function(fit_lists) {
  do.call(rbind, lapply(fit_lists, function(fit_list) {
    do.call(rbind, lapply(fit_list, function(x) {
      if (is.null(x$fit)) return(NULL)
      data.frame(
        group = x$group,
        model = x$model,
        AIC   = AIC(x$fit),
        AICc  = AICc(x$fit),
        BIC   = BIC(x$fit),
        stringsAsFactors = FALSE
      )
    }))
  }))
}

# FUNCTION 1: compare_models_basic

compare_models_basic <- function(...) {
  
  all_metrics <- collect_metrics(list(...))
  
  # For each group and metric, find the winner and the winning margin
  # (= best score subtracted from second-best score)
  per_group <- all_metrics %>%
    group_by(group) %>%
    filter(n() > 1) %>%
    summarise(
      # --- AIC ---
      winner_AIC   = model[which.min(AIC)],
      margin_AIC   = sort(AIC)[2] - min(AIC),   # gap to runner-up
      
      # --- AICc ---
      winner_AICc  = model[which.min(AICc)],
      margin_AICc  = sort(AICc)[2] - min(AICc),
      
      # --- BIC ---
      winner_BIC   = model[which.min(BIC)],
      margin_BIC   = sort(BIC)[2] - min(BIC),
      
      .groups = "drop"
    ) %>%
    mutate(
      # Bin the winning margin into interpretable categories
      across(starts_with("margin_"), ~ cut(.x,
        breaks = c(-Inf, 2, 7, Inf),
        labels = c("< 2", "2-7", "> 7"),
        right  = FALSE
      ), .names = "category_{.col}")
    ) %>%
    # Rename for clarity: category_margin_AIC -> category_AIC
    rename_with(~ gsub("category_margin_", "category_", .x))
  
  # Summary: how many times did each model win, broken down by margin size
  make_summary <- function(winner_col, category_col, label) {
    per_group %>%
      group_by(model = .data[[winner_col]],
               category = .data[[category_col]]) %>%
      summarise(n_groups = n(), .groups = "drop") %>%
      pivot_wider(names_from = category, values_from = n_groups, values_fill = 0) %>%
      mutate(metric = label) %>%
      relocate(metric, model)
  }
  
  summary_table <- bind_rows(
    make_summary("winner_AIC",  "category_AIC",  "AIC"),
    make_summary("winner_AICc", "category_AICc", "AICc"),
    make_summary("winner_BIC",  "category_BIC",  "BIC")
  )
  
  list(
    summary     = summary_table,   # ~model x margin category counts
    per_group   = per_group,       # one row per group with winner + margin
    all_metrics = all_metrics      # raw AIC/AICc/BIC for every group x model
  )
}

# FUNCTION 2: compute_akaike_weights

compute_akaike_weights <- function(...) {
  
  all_metrics <- collect_metrics(list(...))
  
  all_metrics %>%
    group_by(group) %>%
    filter(n() > 1) %>%
    mutate(
      # AICc weights
      delta_AICc  = AICc - min(AICc),
      weight_AICc = exp(-0.5 * delta_AICc) / sum(exp(-0.5 * delta_AICc)),
      
      # AIC weights
      delta_AIC   = AIC - min(AIC),
      weight_AIC  = exp(-0.5 * delta_AIC)  / sum(exp(-0.5 * delta_AIC))
    ) %>%
    select(group, model, weight_AICc, weight_AIC) %>%
    ungroup()
}

# FUNCTION 3: summarise_weights

summarise_weights <- function(weights) {
  
  categorise_weight <- function(w) {
    cut(w,
        breaks = c(-Inf, 0.5, 0.8, 0.9, Inf),
        labels = c("<= 0.5", "> 0.5",
                   "> 0.8",   "> 0.9"),
        right  = TRUE)
  }
  
  make_weight_summary <- function(weight_col, label) {
    weights %>%
      group_by(group) %>%
      # Keep only the model with the highest weight in each group
      slice_max(order_by = .data[[weight_col]], n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      mutate(category = categorise_weight(.data[[weight_col]])) %>%
      group_by(model, category) %>%
      summarise(n_groups = n(), .groups = "drop") %>%
      pivot_wider(names_from = category, values_from = n_groups, values_fill = 0) %>%
      mutate(metric = label) %>%
      relocate(metric, model)
  }
  
  bind_rows(
    make_weight_summary("weight_AICc", "AICc weights"),
    make_weight_summary("weight_AIC",  "AIC weights")
  )
}

# endregion
# ====================================================================
# ====================================================================
# region - Step 7: Evaluate the effect of temperature
# ====================================================================
filter_invalid <- function(df, col) {
  df %>%
    filter(!is.na(.data[[col]]) & !is.nan(.data[[col]]) & !is.infinite(.data[[col]]))
}

extract_coefficients <- function(fit_list, data, group_var = "id_num") {
  do.call(rbind, lapply(fit_list, function(x) {
    if (is.null(x$fit)) return(NULL)
    tryCatch({
      params <- coef(x$fit)
      r      <- params[["r_max"]]
      t_lag  <- params[["t_lag"]]
      if (!is.finite(r) || r <= 0)        return(NULL)
      if (!is.finite(t_lag) || t_lag < 0) return(NULL)
      
      g <- data[as.character(data[[group_var]]) == as.character(x$group), ]
      
      data.frame(
        group              = x$group,
        model              = x$model,
        r_max              = r,
        ln_r_max           = log(r),
        t_lag              = t_lag,
        ln_t_lag           = log(t_lag),
        temp               = unique(g$temp),
        temp_K             = unique(g$temp) + 273.15,
        inv_temp_K         = 1 / (unique(g$temp) + 273.15),
        inv_temp_boltzmann = 1 / (8.617e-5 * (unique(g$temp) + 273.15)),
        species            = unique(g$species),
        medium             = unique(g$medium),
        citation           = unique(g$citation),
        id_no_temp         = unique(g$id_num_no_temp),
        stringsAsFactors   = FALSE
      )
    }, error = function(e) NULL)
  }))
}



# endregion

# ====================================================================
# region - Step 8: Create plots
# ====================================================================


# endregion
# ====================================================================
# region - Step 9: Run the main() function
# ====================================================================

set.seed(123)  # For reproducibility

# ================================================================
# run all three functions
# ================================================================


# Run the fitting functions
  baranyi_fits <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = baranyi_model,
    model_name = "baryanni_fits",
    group_var  = "id_num",
    n_iter     = 3000,
    conv_count = 100,
    max_iter   = 500
  )
# how many converged?
cat(sprintf("Baranyi : %d/%d converged\n",
            sum(sapply(baranyi_fits, function(x) !is.null(x$fit))), length(baranyi_fits)))

  buchanan_fits <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = buchanan_model,
    model_name = "buchanan_fits",
    group_var  = "id_num",
    n_iter     = 3000,
    conv_count = 100,
    max_iter   = 500
  )

cat(sprintf("Buchanan (3000 n_iter, 500 max_iter, conv_count= 100): %d/%d converged\n",
            sum(sapply(buchanan_fits, function(x) !is.null(x$fit))), length(buchanan_fits)))


diagnostics_baranyi <- diagnose_fits(baranyi_fits) %>% summarise_diagnostics()
diagnostics_buchanan <- diagnose_fits(buchanan_fits) %>% summarise_diagnostics()

# run a linear model (simple: y = a + bx)
linear_fits <- run_simple_linear_models(
  data       = data_clean,
  model_name = "linear_fits",
  group_var  = "id_num"
)

# weights for buchanan vs baranyi vs linear
weights <- compute_akaike_weights(buchanan_fits, baranyi_fits, linear_fits)

weight_summary <- summarise_weights(weights)


weights_baranyi_linear <- compute_akaike_weights(baranyi_fits, linear_fits)

weight_summary_baranyi_linear <- summarise_weights(weights_baranyi_linear)


weights_buchanan_linear <- compute_akaike_weights(buchanan_fits, linear_fits)

weight_summary_buchanan_linear <- summarise_weights(weights_buchanan_linear)


weights_buchanan_baranyi <- compute_akaike_weights(buchanan_fits, baranyi_fits)

weight_summary_buchanan_baranyi <- summarise_weights(weights_buchanan_baranyi)


# ================================================================
# thermal performance
# ================================================================

# Extract thermal performance data using extract_coefficients
r_data_buchanan_coeffs <- extract_coefficients(buchanan_fits, data_clean)
r_data_baranyi_coeffs  <- extract_coefficients(baranyi_fits, data_clean)


# filter out rows with a NA, NaN or infite r_max values using pipes

# put the two datasets together for plotting
coef_combined_scaled <- bind_rows(r_data_buchanan_coeffs, r_data_baranyi_coeffs) %>%
  filter_invalid("inv_temp_boltzmann") %>%
  mutate(inv_temp_boltzmann_scaled = scale(inv_temp_boltzmann)) %>%
  # Strip the matrix attributes so it's a simple vector
  mutate(inv_temp_boltzmann_scaled = as.numeric(inv_temp_boltzmann_scaled))


# run r_max your model with the "clean" vector
r_max_mod <- lmer(ln_r_max ~ inv_temp_boltzmann_scaled + model + (1 | medium) + (1 | citation),
                  data = coef_combined_scaled, REML = TRUE)

r_max_mod_check <- check_model(r_max_mod)
r_max_mod_summary <- summary(r_max_mod)

# R2 of r_max_mod
r_max_r2 <- performance::r2(r_max_mod)

## plot it
predictions <- ggpredict(r_max_mod, terms = c("inv_temp_boltzmann_scaled [all]", "model"))

# 2. Plot using your preferred styling
(rmax_plot <- ggplot(predictions, aes(x = x, y = predicted, group = group, color = group)) +
  # Confidence Interval Ribbons
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = group), 
              alpha = 0.2, color = NA) +
  # Prediction Lines
  geom_line(linewidth = 1) +
  # Raw data points (using as.numeric to avoid the matrix error)
  geom_point(data = coef_combined_scaled, 
             aes(x = as.numeric(inv_temp_boltzmann_scaled), y = ln_r_max, color = model), 
             alpha = 0.1, size = 2) +
  # Labels and Theme (matching your muntjac style)
  labs(x = "\nInverse Temperature (Scaled Boltzmann)", 
       y = "ln(r_max)\n",
       color = "Growth Model",
       fill = "Growth Model") +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    axis.title = element_text(size = 14, face = "plain"),
    panel.grid = element_blank(),
    plot.margin = unit(c(1,1,1,1), units = "cm")
  ))

# ggsave as pdf
ggsave("../results/rmax_thermal_performance_plot.pdf", rmax_plot, width = 6, height = 4)

# ======================================================================
# Latex
# ======================================================================

# Extract fixed effects for LaTeX table
fixed_effects <- summary(r_max_mod)$coefficients
fixed_df <- as.data.frame(fixed_effects)
fixed_df$coefficient <- rownames(fixed_df)

# Format fixed effects for LaTeX
cat("\n=== FIXED EFFECTS (for LaTeX table) ===\n")
for(i in 1:nrow(fixed_df)) {
  cat(sprintf("%s & %.2f $\\pm$ %.2f & %.2f \\\\\n",
              fixed_df$coefficient[i],
              fixed_df$Estimate[i],
              fixed_df$`Std. Error`[i],
              fixed_df$`t value`[i]))
}

# Extract random effects variances
random_effects <- as.data.frame(VarCorr(r_max_mod))

cat("\n=== RANDOM EFFECTS (for LaTeX table) ===\n")
for(i in 1:nrow(random_effects)) {
  if(random_effects$grp[i] == "Residual") {
    cat(sprintf("Residuals & %.2f &  \\\\\n", sqrt(random_effects$vcov[i])))
  } else {
    cat(sprintf("%s & %.2f &  \\\\\n", 
                random_effects$grp[i], 
                sqrt(random_effects$vcov[i])))
  }
}

cat("\n=== COMPLETE LaTeX TABLE ===\n")
cat("\\begin{table}[h!]\n")
cat("\\centering\n")
cat("\\caption{\\textit{Coefficients from the linear mixed model examining the relationship between ln(r\\_max) and inverse temperature (scaled Boltzmann units). Coefficients are presented alongside their standard error} (\\textit{SE}). \\textit{The random intercepts for Medium and Citation reflect the variability attributable to these factors. Significance was assumed when} \\textit{$t < -1.96$ or $t > 1.96$}.}\n")
cat("\\vspace{0.5em}\n")
cat("\\label{tab:r_max_model}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("\\multicolumn{3}{c}{\\textbf{Fixed Effects}} \\\\\n")
cat("\\midrule\n")
cat("\\textbf{Coefficient} & \\textbf{Estimate $\\pm$ \\textit{SE}} & \\textbf{\\textit{t} Value} \\\\\n")
cat("\\midrule\n")
for(i in 1:nrow(fixed_df)) {
  cat(sprintf("%s & %.2f $\\pm$ %.2f & %.2f \\\\\n",
              fixed_df$coefficient[i],
              fixed_df$Estimate[i],
              fixed_df$`Std. Error`[i],
              fixed_df$`t value`[i]))
}
cat("\\midrule\n")
cat("\\multicolumn{3}{c}{\\textbf{Random Effects}} \\\\\n")
cat("\\midrule\n")
for(i in 1:nrow(random_effects)) {
  if(random_effects$grp[i] == "Residual") {
    cat(sprintf("Residuals & %.2f &  \\\\\n", sqrt(random_effects$vcov[i])))
  } else {
    cat(sprintf("%s & %.2f &  \\\\\n", 
                random_effects$grp[i], 
                sqrt(random_effects$vcov[i])))
  }
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")

# ======================================================================









# endregion

# ====================================================================
# region - Appendix I: plotting best/worst fits by R²
# ====================================================================

# ============================================================
# Plot best or worst fitting models by R²
# Optionally overlay a second model for comparison
# ============================================================

compute_r2 <- function(fit_list, data, group_var = "id_num") {
  do.call(rbind, lapply(fit_list, function(x) {
    if (!is.list(x) || is.null(x$fit)) return(NULL)
    tryCatch({
      group_data <- data[as.character(data[[group_var]]) == as.character(x$group), ]
      y_obs  <- group_data$log10_popbio
      y_pred <- predict(x$fit)
      ss_res <- sum((y_obs - y_pred)^2)
      ss_tot <- sum((y_obs - mean(y_obs))^2)
      data.frame(group = x$group, model = x$model, r2 = 1 - ss_res / ss_tot)
    }, error = function(e) NULL)
  })) %>% arrange(desc(r2))
}

# ============================================================
# FUNCTION: plot_fits
#
# Arguments:
#   fit_list    - primary model fits (the one being ranked by R²)
#   data        - data_clean
#   n           - how many plots to make
#   top         - TRUE = best fits, FALSE = worst fits
#   group_var   - grouping column
#   export_dir  - if provided, saves PNGs here; NULL prints to screen
#   compare_fit - optional second fit_list to overlay on each plot
# ============================================================
plot_fits <- function(fit_list, data, n = 15, top = TRUE,
                      group_var = "id_num", export_dir = NULL,
                      compare_fit = NULL) {
  
  r2_table <- compute_r2(fit_list, data, group_var)
  selected <- if (top) head(r2_table, n) else tail(r2_table, n)
  
  if (!is.null(export_dir)) dir.create(export_dir, showWarnings = FALSE, recursive = TRUE)
  
  cat(sprintf("Plotting %s %d fits for model: %s\n",
              if (top) "top" else "bottom", n, unique(r2_table$model)))
  
  for (i in seq_len(nrow(selected))) {
    
    g       <- selected$group[i]
    r2_val  <- selected$r2[i]
    fit_obj <- fit_list[[as.character(g)]]
    if (!is.list(fit_obj) || is.null(fit_obj$fit)) next
    
    group_data <- data[as.character(data[[group_var]]) == as.character(g), ]
    t_seq      <- seq(min(group_data$time), max(group_data$time), length.out = 200)
    
    # Primary model predictions
    y_pred <- tryCatch(
      predict(fit_obj$fit, newdata = data.frame(t = t_seq)),
      error = function(e) NULL
    )
    if (is.null(y_pred)) next
    
    pred_df <- data.frame(t = t_seq, y = y_pred,
                          model_line = fit_obj$model)
    
    # Comparison model predictions (if provided)
    compare_obj <- if (!is.null(compare_fit)) compare_fit[[as.character(g)]] else NULL
    if (!is.null(compare_obj) && is.list(compare_obj) && !is.null(compare_obj$fit)) {
      y_compare <- tryCatch(
        predict(compare_obj$fit, newdata = data.frame(t = t_seq)),
        error = function(e) NULL
      )
      if (!is.null(y_compare)) {
        pred_df <- bind_rows(pred_df,
                             data.frame(t = t_seq, y = y_compare,
                                        model_line = compare_obj$model))
      }
    }
    
    p <- ggplot(group_data, aes(x = time, y = log10_popbio)) +
      geom_point(size = 2, alpha = 0.8) +
      geom_line(data = pred_df,
                aes(x = t, y = y, color = model_line),
                linewidth = 1) +
      labs(title    = sprintf("ID: %s", g),
           subtitle = sprintf("R² = %.4f | %s | %s°C",
                              r2_val,
                              paste(unique(group_data$species), collapse = "/"),
                              paste(unique(group_data$temp),    collapse = "/")),
           x     = "Time",
           y     = "log10(Population)",
           color = "Model") +
      theme_bw()
    
    if (!is.null(export_dir)) {
      ggsave(file.path(export_dir, sprintf("id_%s.png", g)),
             plot = p, width = 8, height = 5, dpi = 150)
    } else {
      print(p)
    }
  }
  
  if (!is.null(export_dir))
    cat(sprintf("Saved %d plots to: %s\n", nrow(selected), export_dir))
}

# ============================================================
# Example usage
# ============================================================

# Worst Buchanan fits, with Baranyi overlaid for comparison
#plot_fits(buchanan_fits_3000, data_clean, n = 15, top = FALSE,
#          compare_fit = baranyi_fits)


# Export version
#plot_fits(buchanan_fits_3000, data_clean, n = 15, top = TRUE,
#          export_dir  = "../results/buchanan_best",
#          compare_fit = baranyi_fits_3000)




# endregion

# ===========================================================
# region - Appendix II: plot by weight category
# ============================================================
# FUNCTION: plot_by_weight
#
# Filters groups where a specific model's Akaike weight
# exceeds a threshold, then plots those groups.
#
# Arguments:
#   weights     - output of compute_akaike_weights()
#   target_model - model name to filter on e.g. "buchanan"
#   fit_lists   - named list of fit_lists to overlay on each plot
#                 e.g. list(buchanan = buchanan_fits, baranyi = baranyi_fits)
#   data        - data_clean
#   threshold   - minimum weight to include (default 0.9)
#   weight_col  - "weight_AICc" or "weight_AIC" (default AICc)
#   group_var   - grouping column
#   export_dir  - if provided, saves multi-page PDF here; NULL prints to screen
# ============================================================
plot_by_weight <- function(weights, target_model, fit_lists, data,
                           threshold  = 0.9,
                           weight_col = "weight_AICc",
                           group_var  = "id_num",
                           export_dir = NULL) {
  
  # Filter to groups where target model exceeds the weight threshold
  selected_groups <- weights %>%
    filter(model == target_model,
           .data[[weight_col]] >= threshold) %>%
    arrange(desc(.data[[weight_col]]))
  
  cat(sprintf("Found %d groups where %s has %s >= %.2f\n",
              nrow(selected_groups), target_model, weight_col, threshold))
  
  if (nrow(selected_groups) == 0) {
    message("No groups meet the threshold - try lowering it")
    return(invisible(NULL))
  }
  
  # Create output directory if needed
  if (!is.null(export_dir)) {
    dir.create(export_dir, showWarnings = FALSE, recursive = TRUE)
    # Open PDF device
    pdf_path <- file.path(export_dir, sprintf("%s_weight_plots.pdf", target_model))
    pdf(pdf_path, width = 10, height = 7)
  }
  
  for (i in seq_len(nrow(selected_groups))) {
    
    g      <- selected_groups$group[i]
    w_val  <- selected_groups[[weight_col]][i]
    
    group_data <- data[as.character(data[[group_var]]) == as.character(g), ]
    t_seq      <- seq(min(group_data$time), max(group_data$time), length.out = 200)
    
    # Build prediction lines for every fit_list provided
    pred_df <- do.call(bind_rows, lapply(names(fit_lists), function(m) {
      fit_obj <- fit_lists[[m]][[as.character(g)]]
      if (!is.list(fit_obj) || is.null(fit_obj$fit)) return(NULL)
      y_pred <- tryCatch(
        predict(fit_obj$fit, newdata = data.frame(t = t_seq)),
        error = function(e) NULL
      )
      if (is.null(y_pred)) return(NULL)
      data.frame(t = t_seq, y = y_pred, model_line = m)
    }))
    
    if (nrow(pred_df) == 0) next

    p <- ggplot(group_data, aes(x = time, y = log10_popbio)) +
      geom_point(aes(color = factor(rep)), size = 2, alpha = 0.8) +
      geom_line(data = pred_df,
                aes(x = t, y = y, linetype = model_line),
                linewidth = 1) +
      labs(title    = sprintf("ID: %s", g),
           subtitle = sprintf("%s weight = %.3f | %s | %s°C",
                              target_model, w_val,
                              paste(unique(group_data$species), collapse = "/"),
                              paste(unique(group_data$temp),    collapse = "/")),
           x        = "Time",
           y        = "log10(Population)",
           color    = "Replicate",
           linetype = "Model") +
      theme_bw()
    
    print(p)
  }
  
  if (!is.null(export_dir)) {
    dev.off()
    cat(sprintf("Saved %d plots to: %s\n", nrow(selected_groups), pdf_path))
  }
  
  invisible(NULL)
}

#============================================================
# Example usage:
#============================================================


# sample
# plot_by_weight(weights, target_model = "buchanan_fits",
#               fit_lists = list(buchanan = buchanan_fits, baranyi = baranyi_fits, linear = linear_fits),
#               data = data_clean,
#               threshold = 0.95,
#               weight_col = "weight_AICc",
#               export_dir = "../results/buchanan_weighted")


# endregion

# ============================================================
# region - Appendix III: the summary statistics
# ============================================================


# --- Data summary ---
n_timepoints <- nrow(data_clean)
n_curves     <- length(unique(data_clean$id_num))
n_species    <- length(unique(data_clean$species))
n_substrates <- length(unique(data_clean$medium))
n_citations  <- length(unique(data_clean$citation))

# --- Temperature summary ---
temps        <- unique(data_clean$temp)
n_temps      <- length(temps)
temp_min     <- min(temps, na.rm = TRUE)
temp_max     <- max(temps, na.rm = TRUE)
temp_sd      <- round(sd(data_clean$temp, na.rm = TRUE), 2)
mean_temp    <- round(mean(data_clean$temp, na.rm = TRUE), 2)

# --- Convergence counts (using your best fits) ---
n_buchanan <- sum(sapply(buchanan_fits, function(x) !is.null(x$fit)))
n_baranyi  <- sum(sapply(baranyi_fits,  function(x) !is.null(x$fit)))

cat(sprintf(
"I attempted to fit %d growth curves across %d time points, covering %d species/strains, %d mediums, and %d citations. %d different temperature values were recorded, ranging from %.1f to %.1f °C, with an average of %.2f °C (SD = %.2f °C). The Buchanan model converged %d times and the Baranyi converged %d times.\n",
  n_curves, n_timepoints,
  n_species, n_substrates, n_citations,
  n_temps, temp_min, temp_max, mean_temp, temp_sd,
  n_buchanan, n_baranyi
))


# solids vs liquids:
data_clean %>%
  mutate(state = case_when(
    medium %in% c("APT Broth", "ESAW", "MRS", "MRS broth", "TSB", "Z8",
                  "Pasteurised Double Cream", "Pasteurised Full-fat Milk",
                  "Pasteurised Skim Milk", "UHT Double Cream",
                  "UHT Full-fat Milk", "UHT Skim Milk") ~ "liquid",
    medium %in% c("C02 Beef Striploins", "Cooked Chicken Breast",
                  "Raw Chicken Breast", "Salted Chicken Breast",
                  "Vacuum Beef Striploins", "TGE agar") ~ "solid",
    TRUE ~ "unknown"
  )) %>%
  group_by(state) %>%
  summarise(n_ids = n_distinct(id_num))



# how many unique IDs per medium:
data_clean %>%
  group_by(medium) %>%
  summarise(n_ids = n_distinct(id_num))

# ===========================================================
# region - Appendix VII: Sample size analysis for high-weight models
# ===========================================================

# ============================================================
# FUNCTION: analyze_sample_sizes
#
# Analyzes the distribution of sample sizes (n time points) for
# growth curves where a model has high Akaike weight (>0.9)
#
# Arguments:
#   weights     - output from compute_akaike_weights()
#   data        - data_clean
#   threshold   - minimum weight threshold (default 0.9)
#   weight_col  - "weight_AICc" or "weight_AIC" (default "weight_AICc")
#   group_var   - grouping column (default "id_num")
#
# Returns:
#   data.frame with group, model, weight, and n_points
# ============================================================
analyze_sample_sizes <- function(weights, data, 
                                 threshold  = 0.9,
                                 weight_col = "weight_AICc",
                                 group_var  = "id_num") {
  
  # Calculate sample sizes per group
  sample_sizes <- data %>%
    group_by(!!sym(group_var)) %>%
    summarise(n_points = n(), .groups = "drop") %>%
    rename(group = !!sym(group_var))
  
  # Filter weights above threshold and merge with sample sizes
  high_weight_data <- weights %>%
    filter(.data[[weight_col]] >= threshold) %>%
    left_join(sample_sizes, by = "group") %>%
    select(group, model, weight = !!sym(weight_col), n_points)
  
  return(high_weight_data)
}

# ============================================================
# FUNCTION: plot_sample_size_density
#
# Creates density plots of sample sizes for each model with
# high Akaike weights
#
# Arguments:
#   sample_size_data - output from analyze_sample_sizes()
#   export_dir       - directory to save plot (default "../results")
#   width            - plot width (default 10)
#   height           - plot height (default 6)
# ============================================================
plot_sample_size_density <- function(sample_size_data,
                                     export_dir = "../results",
                                     width = 10,
                                     height = 6) {
  
  # Count observations per model
  model_counts <- sample_size_data %>%
    group_by(model) %>%
    summarise(n = n(), .groups = "drop")
  
  cat("\nSample size summary for high-weight models (w >= 0.9):\n")
  print(model_counts)
  
  # Create density plot
  p <- ggplot(sample_size_data, aes(x = n_points, fill = model)) +
    geom_density(alpha = 0.5) +
    geom_rug(aes(color = model), alpha = 0.3) +
    labs(
      x = "Number of Time Points",
      y = "Density",
      title = "Sample Size Distribution for High-Weight Models",
      subtitle = "Models with Akaike weight ≥ 0.9",
      fill = "Model",
      color = "Model"
    ) +
    theme_bw() +
    theme(legend.position = "bottom")
  
  # Save plot
  filename <- file.path(export_dir, "sample_size_density_high_weight.pdf")
  ggsave(filename, plot = p, width = width, height = height)
  message(sprintf("Saved: %s", filename))
  
  invisible(p)
}

# ============================================================
# FUNCTION: plot_sample_size_boxplot
#
# Creates boxplots comparing sample sizes across models
#
# Arguments:
#   sample_size_data - output from analyze_sample_sizes()
#   export_dir       - directory to save plot (default "../results")
#   width            - plot width (default 10)
#   height           - plot height (default 6)
# ============================================================
plot_sample_size_boxplot <- function(sample_size_data,
                                     export_dir = "../results",
                                     width = 10,
                                     height = 6) {
  
  # Summary statistics
  summary_stats <- sample_size_data %>%
    group_by(model) %>%
    summarise(
      n_curves = n(),
      mean_points = mean(n_points),
      median_points = median(n_points),
      sd_points = sd(n_points),
      min_points = min(n_points),
      max_points = max(n_points),
      .groups = "drop"
    )
  
  cat("\nSummary statistics by model:\n")
  print(summary_stats)
  
  # Create boxplot
  p <- ggplot(sample_size_data, aes(x = model, y = n_points, fill = model)) +
    geom_boxplot(alpha = 0.7, outlier.shape = 21) +
    geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red") +
    labs(
      x = "Model",
      y = "Number of Time Points",
      title = "Sample Size Comparison Across Models",
      subtitle = "Models with Akaike weight ≥ 0.9 (red diamond = mean)"
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  # Save plot
  filename <- file.path(export_dir, "sample_size_boxplot_high_weight.pdf")
  ggsave(filename, plot = p, width = width, height = height)
  message(sprintf("Saved: %s", filename))
  
  invisible(p)
}


# endregion


# ===========================================================
# region - Appendix VIII: bibtex citation summary
# ===========================================================
# Get citations for all loaded packages
packages <- c("ggplot2", "ggeffects", "tidyverse", "minpack.lm", 
              "nls.multstart", "AICcmodavg", "zoo", "nlstools", 
              "lme4", "lmerTest", "performance", "see")

# Extract BibTeX entries
for (pkg in packages) {
  cat("\n\n\n")
  print(toBibtex(citation(pkg)))
}
