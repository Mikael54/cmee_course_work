rm(list = ls()) #clears environment

library(birdnetR)


# Initialise a BirdNET model
model <- birdnet_model_tflite("v2.4")

## First run Monkswood
# Set path to the folder with WAV files
folder_path <- "../sandbox/Monkswood_dawn"

# List all WAV files
wav_files <- list.files(folder_path, pattern = "\\.wav$", full.names = TRUE)

# Loop through each WAV file and run predictions
Monkswood_all_predictions <- lapply(wav_files, function(f) {
  preds <- predict_species_from_audio_file(model, f)
  # Add filename as a new column
  preds$file <- basename(f)
  return(preds)
})

# Combine into one dataframe
Monkswood_all_predictions_df <- do.call(rbind, Monkswood_all_predictions)

## Now run Parsonage
# Path to the folder with WAV files
folder_path <- "../sandbox/Parsonage_dawn"

# List all WAV files
wav_files <- list.files(folder_path, pattern = "\\.wav$", full.names = TRUE)

# Loop through each WAV file and run predictions
Parsonage_all_predictions <- lapply(wav_files, function(f) {
  preds <- predict_species_from_audio_file(model, f)
  # Add filename as a new column
  preds$file <- basename(f)
  return(preds)
})

# Combine into one dataframe
Parsonage_all_predictions_df <- do.call(rbind, Parsonage_all_predictions)

#set your wd and save the files
write.csv(Monkswood_all_predictions_df, "../results/BirdNET_Monkswood.csv")
write.csv(Parsonage_all_predictions_df, "../results/BirdNET_Parsonage.csv")