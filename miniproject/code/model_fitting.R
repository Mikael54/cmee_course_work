
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

  # ----------------------------------------------------------
  # r_max via rolling regression
  # Rolls a window of num_points across [N, t], fits lm in each
  # window, and takes the maximum slope as r_max.
  # Falls back to finite-difference estimate if rolling fails
  # (e.g. too few points for the window).
  # ----------------------------------------------------------
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

  # ----------------------------------------------------------
  # t_lag: time at the start of the window with the maximum rolling slope,
  # i.e. start of the steepest linear segment, not the end.
  # Falls back to time of maximum curvature if rolling fails.
  # ----------------------------------------------------------
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
# step 4: Run the model
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
    response   <- group_data$log10_popbio
    fit_data   <- data.frame(t = group_data$time, y = response)
    starts     <- get_start_params(group_data)
    params     <- names(formals(model_fn))[-1]
    start_list <- starts[params]

    # Assumes log scale - all bounds are for log-transformed data
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

    fit <- nls_multstart(fmla,
                         data              = fit_data,
                         iter              = n_iter,
                         start_lower       = start_lower,
                         start_upper       = start_upper,
                         convergence_count = conv_count,
                         control           = nls.lm.control(maxiter = max_iter))
    
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


# ====================================================================
# step 5: Run model diagnostic
# ====================================================================

# ====================================================================
# step 6: Run model evaluation
# ====================================================================

# ====================================================================
# step 7: Evaluate the effect of temperature
# ====================================================================

# ====================================================================
# step 8: plot any results
# ====================================================================

# ====================================================================
# step 9: run the main() function
# ====================================================================