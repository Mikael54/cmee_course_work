# 1. Unset any forced Python path
Sys.unsetenv("RETICULATE_PYTHON")

# 2. Load reticulate and point to your actual Python
library(reticulate)
use_python("/usr/bin/python3", required = TRUE)



# 3. Make sure Python has the birdnet dependencies
py_install(c("tensorflow", "birdnetlib", "numpy", "soundfile"))

# 4. Confirm reticulate sees the right Python
py_config()