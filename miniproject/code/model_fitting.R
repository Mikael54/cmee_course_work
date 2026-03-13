# preamble


# ====================================================================
# region - Load libraries
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
require("patchwork")


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
      t_lag = max(4, start_list$t_lag  * tlag_upper),   # minimum = 4
      r_max = max(1,start_list$r_max  * r_max_upper)   # minimum = 1
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
                    control           = nls.lm.control(maxiter = max_iter),
                    supp_errors = 'Y'))
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
# ====================================================================
# region - Step 5: Run model evaluation
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

# FUNCTION: compute_akaike_weights

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
        breaks = c(-Inf, 0.5, 0.8, 0.9, 0.95, Inf),
        labels = c("<= 0.5", "> 0.5",
                   "> 0.8",   "> 0.9",   "> 0.95"),
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
# region - Step 6: Evaluate the effect of temperature
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
# region - Step 7: Create plots
# ====================================================================

# FUNCTION: plot_highest_weight_example
#
# Creates a plot for the group with highest AICc weight for a target model
plot_highest_weight_example <- function(weights, target_model, fit_lists, data,
                                        weight_col = "weight_AICc",
                                        group_var = "id_num",
                                        show_legend = FALSE) {
  
  # Find group with highest weight for target model
  best_group <- weights %>%
    filter(model == target_model) %>%
    arrange(desc(.data[[weight_col]])) %>%
    slice(1)
  
  if (nrow(best_group) == 0) {
    stop(sprintf("No data found for model: %s", target_model))
  }
  
  g <- best_group$group
  w_val <- best_group[[weight_col]]
  
  group_data <- data[as.character(data[[group_var]]) == as.character(g), ]
  t_seq <- seq(min(group_data$time), max(group_data$time), length.out = 200)
  
  # Build prediction lines for all models
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
  
  # Create clean model labels
  pred_df <- pred_df %>%
    mutate(model_label = case_when(
      model_line == "buchanan_fits" ~ "Buchanan",
      model_line == "baryanni_fits" ~ "Baranyi",
      model_line == "linear_fits" ~ "Linear",
      TRUE ~ model_line
    ))
  
  target_label <- case_when(
    target_model == "buchanan_fits" ~ "Buchanan",
    target_model == "baryanni_fits" ~ "Baranyi",
    target_model == "linear_fits" ~ "Linear",
    TRUE ~ target_model
  )
  
  p <- ggplot(group_data, aes(x = time, y = log10_popbio)) +
    geom_point(size = 3, alpha = 0.6) +
    geom_line(data = pred_df,
              aes(x = t, y = y, color = model_label),
              linewidth = 1) +
    labs(
      title = sprintf("Highest Akaike Weight %s Model", target_label),
      x = "Time",
      y = expression(log[10]~"(Population)"),
      color = "Model"
    ) +
    scale_color_manual(
      values = c("Buchanan" = "#EE7600", "Baranyi" = "#00868B", "Linear" = "#8B008B")
    ) +
    theme_bw() +
    theme(
      axis.text.x = element_text(size = 12),
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "plain"),
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      panel.grid = element_blank(),
      plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
      legend.position = if (show_legend) "bottom" else "none",
      legend.text = element_text(size = 12),
      legend.title = element_blank()
    )
  
  return(p)
}

# endregion
# ====================================================================
# region - Step 8: Main function
# ====================================================================

main <- function() {
  
  # Load the data
  data_clean <- read.csv("../results/data_clean.csv", header = TRUE)
  
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
    n_iter     = 4000,
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
    n_iter     = 4000,
    conv_count = 100,
    max_iter   = 500
  )

cat(sprintf("Buchanan: %d/%d converged\n",
            sum(sapply(buchanan_fits, function(x) !is.null(x$fit))), length(buchanan_fits)))


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


# export samples

# Create sample growth curve plots for highest AICc weight of each model
fit_lists_all <- list(
  buchanan_fits = buchanan_fits,
  baryanni_fits = baranyi_fits,
  linear_fits = linear_fits
)

plot_buchanan <- plot_highest_weight_example(weights, "buchanan_fits", fit_lists_all, data_clean)
plot_baranyi <- plot_highest_weight_example(weights, "baryanni_fits", fit_lists_all, data_clean)
plot_linear <- plot_highest_weight_example(weights, "linear_fits", fit_lists_all, data_clean, show_legend = TRUE)

# Combine plots vertically and save
combined_plot <- plot_buchanan / plot_baranyi / plot_linear
ggsave("../results/sample_curves.pdf", combined_plot, width = 10, height = 15, dpi = 300)

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
  mutate(inv_temp_boltzmann_scaled = scale(inv_temp_boltzmann),
      inv_temp_K_scaled = scale(inv_temp_K)) %>%
  # Strip the matrix attributes so it's a simple vector
  mutate(inv_temp_boltzmann_scaled = as.numeric(inv_temp_boltzmann_scaled),
         inv_temp_K_scaled = as.numeric(inv_temp_K_scaled))


# run r_max your model with the "clean" vector
r_max_mod <- lmer(ln_r_max ~ inv_temp_K_scaled + model + (1 | medium) + (1 | citation),
                  data = coef_combined_scaled, REML = TRUE)

r_max_mod_check <- check_model(r_max_mod)
r_max_mod_summary <- summary(r_max_mod)

#R squared
performance::r2(r_max_mod)

## plot it
predictions <- ggpredict(r_max_mod, terms = c("inv_temp_K_scaled [all]", "model"))

# 2. Plot using your preferred styling
(rmax_plot <- ggplot(predictions, aes(x = x, y = predicted, group = group, color = group)) +
  # Confidence Interval Ribbons
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = group), 
              alpha = 0.2, color = NA) +
  # Prediction Lines
  geom_line(linewidth = 1) +
  # Raw data points (using as.numeric to avoid the matrix error)
  geom_point(data = coef_combined_scaled, 
             aes(x = as.numeric(inv_temp_K_scaled), y = ln_r_max, color = model), 
             alpha = 0.3, size = 2) +
  # Labels and Theme (matching your muntjac style)
  labs(x = expression(paste("\nStandardised Inverse Temperature (K"^-1*")")), 
       y = expression(ln(r[max])),
       color = "Growth Model",
       fill = "Growth Model") +
  scale_color_manual(
    values = c("buchanan_fits" = "#EE7600", "baryanni_fits" = "#00868B"),  # your existing colors
    labels = c("buchanan_fits" = "Buchanan", "baryanni_fits" = "Baranyi")
  ) +
  scale_fill_manual(
    values = c("buchanan_fits" = "#EE7600", "baryanni_fits" = "#00868B"),
    labels = c("buchanan_fits" = "Buchanan", "baryanni_fits" = "Baranyi")
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    axis.title = element_text(size = 14, face = "plain"),
    panel.grid = element_blank(),
    plot.margin = unit(c(1,1,1,1), units = "cm")
  ))

# ggsave as pdf
ggsave("../results/rmax_thermal_performance_plot.pdf", rmax_plot, width = 12, height = 8)


}

# endregion
# ====================================================================
# Execute main function
# ====================================================================

main()
