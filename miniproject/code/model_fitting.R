
# preamble



# ====================================================================
# load libraries and data
# ====================================================================

require("ggplot2")
require("tidyverse")
require("minpack.lm")
require("nls.multstart")
require("AICcmodavg")
require("zoo")

# load the data
data_clean <- read.csv("../results/data_clean.csv", header = TRUE)

# ====================================================================
# Define growth model functions
# ====================================================================

# cubic polynomial model
cubic_model <- function(t, a, b, c, d){
  a*t^3 + b*t^2 + c*t + d
}

# Logistic 
logistic_model <- function(t, r_max, N_max, N_0){ 
  return(N_0 * N_max * exp(r_max * t)/(N_max + N_0 * (exp(r_max * t) - 1)))
}
# logistic log 10
logistic_model_log10 <- function(t, r_max, N_max, N_0){
  n0   <- 10^N_0
  nmax <- 10^N_max
  log10(n0 * nmax * exp(r_max * t) / (nmax + n0 * (exp(r_max * t) - 1)))
}

# Gompertz
  gompertz_model <- function(t, r_max, N_max, N_0, t_lag){ # Modified gompertz growth model (Zwietering 1990)
  return(N_0 + (N_max - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((N_max - N_0) * log(10)) + 1)))
}

# Baranyi model
baranyi_model <- function(t, r_max, N_max, N_0, t_lag){  # Baranyi model (Baranyi 1993)
  return(N_max + log10((-1+exp(r_max*t_lag) + exp(r_max*t))/(exp(r_max*t) - 1 + exp(r_max*t_lag) * 10^(N_max-N_0))))
}

# Buchanan model
buchanan_model <- function(t, r_max, N_max, N_0, t_lag){ # Buchanan model - three phase logistic (Buchanan 1997)
  return(N_0 + (t >= t_lag) * (t <= (t_lag + (N_max - N_0) * log(10)/r_max)) * r_max * (t - t_lag)/log(10) + (t >= t_lag) * (t > (t_lag + (N_max - N_0) * log(10)/r_max)) * (N_max - N_0))
}

# ====================================================================
# step 3: extract the parameters
# ====================================================================

# Helper: fit a linear model to a rolling window and return slope and intercept
roll_regress <- function(x) {
  temp <- as.data.frame(x)
  colnames(temp) <- c("N", "t")
  mod <- lm(N ~ t, data = temp)
  data.frame(
    slope     = coef(mod)[["t"]],
    intercept = coef(mod)[["(Intercept)"]],
    rsq       = summary(mod)$r.squared,
    stringsAsFactors = FALSE
  )
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

# ====================================================================
# step 4: Run the growth models on multistart with NLSLM
# ====================================================================

# NEED TO TEST OUT VARIATIONS OF MAX_ITER, started at 1500 cause thats what worked best before though

run_growth_models_multistart <- function(data,
                                         model_fn,
                                         model_name,
                                         group_var  = "id_num",
                                         n_iter     = 1500,
                                         conv_count = 100,
                                         max_iter   = 1500) {
  groups <- unique(data[[group_var]])
  results <- lapply(groups, function(g) {
    group_data <- data[data[[group_var]] == g, ]
    fit_data   <- data.frame(t = group_data$time, y = group_data$log10_popbio)
    starts     <- get_start_params(group_data)
    params     <- names(formals(model_fn))[-1]
    start_list <- starts[params]

    start_upper_all <- list(
      N_0   = start_list$N_0   + 2,
      N_max = start_list$N_max + 2,
      t_lag = max(20, start_list$t_lag * 20),
      r_max = max(10, start_list$r_max * 50)
    )
    start_lower_all <- list(
      N_0   = start_list$N_0   - 2,
      N_max = start_list$N_0,
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

# Code for linear models
run_linear_models <- function(data, model_fn, model_name, group_var = "id_num") {
  
  # Infer polynomial degree from number of parameters (excluding t)
  degree <- length(formals(model_fn)) - 1
  
  groups  <- unique(data[[group_var]])
  results <- lapply(groups, function(g) {
    group_data <- data[data[[group_var]] == g, ]
    fit_data   <- data.frame(t = group_data$time, y = group_data$log10_popbio)
    fit <- tryCatch(
      lm(y ~ poly(t, degree, raw = TRUE), data = fit_data),
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
# ====================================================================
# step 4.5: run some models (to delete later)
# ====================================================================

gompertz_fits <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = gompertz_model,
  model_name = "gompertz_multistart",
  group_var  = "id_num"
)
# run logistic model with log10 transformation
logistic_log10_fits <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = logistic_model_log10,
  model_name = "logistic_log10_multistart",
  group_var  = "id_num"
)

# run baranyi model
baranyi_fits <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = baranyi_model,
  model_name = "baranyi_multistart",
  group_var  = "id_num"
)
# run buchanan model
buchanan_fits <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = buchanan_model,
  model_name = "buchanan_multistart",
  group_var  = "id_num"
)

# say the amount of convergences for each model
cat("Gompertz converged for", sum(sapply(gompertz_fits, function(x) !is.null(x$fit))), "out of", length(gompertz_fits), "groups.\n")
cat("Logistic (log10) converged for", sum(sapply(logistic_log10_fits, function(x) !is.null(x$fit))), "out of", length(logistic_log10_fits), "groups.\n")
cat("Baranyi converged for", sum(sapply(baranyi_fits, function(x) !is.null(x$fit))), "out of", length(baranyi_fits), "groups.\n")
cat("Buchanan converged for", sum(sapply(buchanan_fits, function(x) !is.null(x$fit))), "out of", length(buchanan_fits), "groups.\n")


# svae all models as model_fit_default_parameters
model_fit_default_parameters <- list(
  gompertz_multistart = gompertz_fits,
  logistic_log10_multistart = logistic_log10_fits,
  baranyi_multistart = baranyi_fits,
  buchanan_multistart = buchanan_fits
)

# THESE VALUE ARE MUCH BETTER THAN THE DEFAULT ONES- HIGHER CONVERGENCE RATE FOR BUCHAN
# now rerun the model with lower max iterations and convergence count to see if it makes a difference
gompertz_fits_low_iter <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = gompertz_model,
  model_name = "gompertz_multistart_low_iter",
  group_var  = "id_num",
  n_iter     = 5000,
  conv_count = 100,
  max_iter   = 1000
)
logistic_log10_fits_low_iter <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = logistic_model_log10,
  model_name = "logistic_log10_multistart_low_iter",
  group_var  = "id_num",
  n_iter     = 5000,
  conv_count = 100,
  max_iter   = 1000
)
baranyi_fits_low_iter <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = baranyi_model,
  model_name = "baranyi_multistart_low_iter",
  group_var  = "id_num",
  n_iter     = 5000,
  conv_count = 100,
  max_iter   = 1000
)
buchanan_fits_low_iter <- run_growth_models_multistart(
  data       = data_clean,
  model_fn   = buchanan_model,
  model_name = "buchanan_multistart_low_iter",
  group_var  = "id_num",
  n_iter     = 5000,
  conv_count = 100,
  max_iter   = 1000
)

# say the amount of convergences for each model
cat("Gompertz (low iter) converged for", sum(sapply(gompertz_fits_low_iter, function(x) !is.null(x$fit))), "out of", length(gompertz_fits_low_iter), "groups.\n")
cat("Logistic (log10, low iter) converged for", sum(sapply(logistic_log10_fits_low_iter, function(x) !is.null(x$fit))), "out of", length(logistic_log10_fits_low_iter), "groups.\n")
cat("Baranyi (low iter) converged for", sum(sapply(baranyi_fits_low_iter, function(x) !is.null(x$fit))), "out of", length(baranyi_fits_low_iter), "groups.\n")
cat("Buchanan (low iter) converged for", sum(sapply(buchanan_fits_low_iter, function(x) !is.null(x$fit))), "out of", length(buchanan_fits_low_iter), "groups.\n")




# RUn the same models again- but include time bechnmarking to see if it makes a difference
logistic_time <- system.time(
  logistic_log10_fits_500 <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = logistic_model_log10,
    model_name = "logistic_log10_multistart_500",
    group_var  = "id_num",
    n_iter     = 5000,
    conv_count = 100,
    max_iter   = 500
  )
)

buchanan_time <- system.time(
  buchanan_fits_500 <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = buchanan_model,
    model_name = "buchanan_multistart_500",
    group_var  = "id_num",
    n_iter     = 5000,
    conv_count = 100,
    max_iter   = 500
  )
)

cat(sprintf("Logistic (500 max_iter): %.1f seconds | %d/%d converged\n",
            logistic_time["elapsed"],
            sum(sapply(logistic_log10_fits_500, function(x) !is.null(x$fit))),
            length(logistic_log10_fits_500)))

cat(sprintf("Buchanan (500 max_iter): %.1f seconds | %d/%d converged\n",
            buchanan_time["elapsed"],
            sum(sapply(buchanan_fits_500, function(x) !is.null(x$fit))),
            length(buchanan_fits_500)))

# compare 500 vs 1000 max_iter fits
model_comparison_500_vs_1000 <- compare_models_basic(logistic_log10_fits_500, logistic_log10_fits_low_iter)
print(model_comparison_500_vs_1000$summary)

model_comparison_buchanan_500_vs_1000 <- compare_models_basic(buchanan_fits_500, buchanan_fits_low_iter)
print(model_comparison_buchanan_500_vs_1000$summary)



# compare buchana and baranyi with 1000 max_iter
model_comparison_buchanan_vs_baranyi <- compare_models_basic(buchanan_fits_low_iter, baranyi_fits_low_iter)
print(model_comparison_buchanan_vs_baranyi$summary)

weights_buchanan_baranyi <- compute_akaike_weights(buchanan_fits_low_iter, baranyi_fits_low_iter)
summary_weights_buchanan_baranyi <- summarise_weights(weights_buchanan_baranyi)
print(summary_weights_buchanan_baranyi)

# compare sample size of of growth curves for when buchanan wins vs baranyi wins
buchanan_wins <- model_comparison_buchanan_vs_baranyi$per_group %>%
  filter(winner_AICc == "buchanan_multistart_low_iter") %>%
  pull(group)

baranyi_wins <- model_comparison_buchanan_vs_baranyi$per_group %>%
  filter(winner_AICc == "baranyi_multistart_low_iter") %>%
  pull(group)

# count number of unique groups in each category
cat("Buchanan wins for", length(unique(buchanan_wins)), "groups.\n")
cat("Baranyi wins for", length(unique(baranyi_wins)), "groups.\n")

# summary statistics for the number of time points in each group winner with 
data_clean %>%
  group_by(id_num) %>%
  summarise(n_time_points = n()) %>%
  mutate(winner = case_when(
    id_num %in% buchanan_wins ~ "Buchanan",
    id_num %in% baranyi_wins ~ "Baranyi",
    TRUE ~ "Neither"
  )) %>%
  group_by(winner) %>%
  summarise(mean_time_points = mean(n_time_points),
            sd_time_points = sd(n_time_points),
            .groups = "drop")


#buchanan iter vs time
buchanan_time_N_iter_1500 <- system.time(
  buchanan_fits_1500 <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = buchanan_model,
    model_name = "buchanan_multistart_500",
    group_var  = "id_num",
    n_iter     = 2500,
    conv_count = 100,
    max_iter   = 1000
  )
)

cat(sprintf("Buchanan (500 max_iter): %.1f seconds | %d/%d converged\n",
            buchanan_time_N_iter_1500["elapsed"],
            sum(sapply(buchanan_fits_1500, function(x) !is.null(x$fit))),
            length(buchanan_fits_1500)))



# test 3
buchanan_time_N_iter_3000 <- system.time(
  buchanan_fits_3000 <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = buchanan_model,
    model_name = "buchanan_multistart_3000_max_iter_500_",
    group_var  = "id_num",
    n_iter     = 3000,
    conv_count = 100,
    max_iter   = 500
  )
)


cat(sprintf("Buchanan (500 max_iterz, 3000 iterations): %.1f seconds | %d/%d converged\n",
            buchanan_time_N_iter_3000["elapsed"],
            sum(sapply(buchanan_fits_3000, function(x) !is.null(x$fit))),
            length(buchanan_fits_3000)))

buchanan_time_N_iter_3000_400 <- system.time(
  buchanan_fits_3000_400 <- run_growth_models_multistart(
    data       = data_clean,
    model_fn   = buchanan_model,
    model_name = "buchanan_multistart_3000_max_iter_400_",
    group_var  = "id_num",
    n_iter     = 3000,
    conv_count = 100,
    max_iter   = 400
  )
)


cat(sprintf("Buchanan (400 max_iter, 3000 iterations): %.1f seconds | %d/%d converged\n",
            buchanan_time_N_iter_3000_400["elapsed"],
            sum(sapply(buchanan_fits_3000_400, function(x) !is.null(x$fit))),
            length(buchanan_fits_3000_400)))


# this is the best one
# going from 3000 to 5 000 iterations only increased convergence by 1 group, but increased time by 100 seconds


# compare buchana with 3000 iterations vs 5000 iterations
comparison_buchanan_3000_vs_5000 <- compare_models_basic(buchanan_fits_3000, buchanan_fits_500)
print(comparison_buchanan_3000_vs_5000$summary)


# ====================================================================
# step 5: Run model diagnostic
# ====================================================================

# ====================================================================
# step 6: Run model evaluation
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
#
# For each group, finds the winning model and records how far
# ahead it is of the second-best model.

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
#
# For each group, computes Akaike weights from AICc (and AIC):
#   1. delta_i  = AICc_i - AICc_min
#   2. L_i      = exp(-0.5 * delta_i)     (relative likelihood)
#   3. w_i      = L_i / sum(L)            (Akaike weight)

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
#
# Takes the output of compute_akaike_weights.
# For each model, counts how many groups it had a weight in each size bucket.

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


# ====================================================================
# step 6.5: evaluate the models
# ====================================================================

# delta AIC/AICc/BIC and winner tables
model_comparison <- compare_models_basic(gompertz_fits, logistic_log10_fits, baranyi_fits, buchanan_fits)
print(model_comparison$summary)


# logistic vs buchanan basic comparison
model_comparison_2 <- compare_models_basic(logistic_log10_fits, buchanan_fits)
print(model_comparison_2$summary)

# logistic vs Gompertz basic comparison
model_comparison_3 <- compare_models_basic(logistic_log10_fits, gompertz_fits)
print(model_comparison_3$summary)


# logistic vs buchanan basic comparison
model_comparison_4 <- compare_models_basic(logistic_log10_fits, baranyi_fits)
print(model_comparison_4$summary)

# print akaike weights
weights <- compute_akaike_weights(gompertz_fits, logistic_log10_fits, baranyi_fits, buchanan_fits)
print(head(weights))
# summarize the weights into categories
weight_summary <- summarise_weights(weights)
print(weight_summary)


# evaluate low iter vs high it for logistic
model_comparison_low_iter <- compare_models_basic(logistic_log10_fits_low_iter, logistic_log10_fits)
print(model_comparison_low_iter$summary)

logistic_log10_fits_low_iter


# now for buchanan
model_comparison_low_iter_buchanan <- compare_models_basic(buchanan_fits_low_iter, buchanan_fits)
print(model_comparison_low_iter_buchanan$summary)

# ====================================================================
# step 7: Evaluate the effect of temperature
# ====================================================================

# ====================================================================
# step 8: plot any results
# ====================================================================

# ====================================================================
# step 9: run the main() function
# ====================================================================