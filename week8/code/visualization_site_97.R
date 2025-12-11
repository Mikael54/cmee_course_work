# Clear your global environment 
rm(list = ls()) 

# Set your working directory 
setwd("../sandbox/site_97") 

# Download packages needed to handle sound files & create spectrograms 
#install.packages('tuneR') 
#install.packages('seewave') 

#load packages
library(tuneR) 
library(seewave) 


list.files(pattern = "wav") 



# soundfile:

# Read in a single sound file
soundfile <- readWave("2MM06378_20251010_141500.wav")

# OR alternatively multiple
soundfile_multiple <- readWave(list.files(pattern = ".wav")[1]) 

class(soundfile) # Check the class of your object to make sure its readable 





# filter and spectogram:
# Filter out unwanted frequencies using 'fir()' function 
soundfile <- fir(wave = soundfile, 
                 from = 1000, # lower bound frequency in Hz
                 to = 20000, # upper bound frequency in Hz 
                 bandpass = TRUE, output = "Wave") 

# Create a spectrogram using 'spectro()' function from the seewave package
spectro(wave = soundfile, fastdisp=TRUE)




# see specific types of data:

#You can customise to see different parts of the soundscape and change colours
#Lets try flim= 1,8 and tlim=10,20
spectro(wave = soundfile, fastdisp=TRUE,
        flim = c(0,20), # Set frequency limits of the spectrogram (kHz) 
        tlim = c(36,39), #Set displayed time limits of the recording (sec) 
        scale = TRUE, # Keeps the amplitude scale bar (FALSE to remove) 
        colgrid = "gray", # Changes colour of the background grid 
        palette = temp.colors, # Changes the colour palette 
        dB="max0", 
        cex.axis = 1.5, # Increase the axes label size 
        cex.lab = 2) # Increase axes titles size) 





# specific call:
#Now lets try flim= 1,8 and tlim=14,15 to see a specific call
spectro(wave = soundfile, fastdisp=TRUE,
        flim = c(1,8), # Set frequency limits of the spectrogram (kHz) 
        tlim = c(14,15), #Set displayed time limits of the recording (sec) 
        scale = TRUE, # Keeps the amplitude scale bar (FALSE to remove) 
        colgrid = "gray", # Changes colour of the background grid 
        palette = temp.colors, # Changes the colour palette 
        dB="max0", 
        cex.axis = 1.5, # Increase the axes label size 
        cex.lab = 2) # Increase axes titles size) 




# export as a jpeg:

# You can also save your spectrogram as a jpeg file to your device 
# Specify the file path if different to your working directory 
# Specify the dimension sizes of the final image 
jpeg("../../results/Spectrogram_zoomed.jpg", width = 900, height = 500)
spectro(wave = soundfile, 
        flim = c(1,8), # Set frequency limits of the spectrogram (kHz) 
        tlim = c(14,15), #Set displayed time limits of the recording (sec) 
        scale = TRUE, # Keeps the amplitude scale bar (FALSE to remove) 
        colgrid = "gray", # Changes colour of the background grid 
        palette = temp.colors, # Changes the colour palette 
        dB="max0", 
        cex.axis = 1.5, # Increase the axes label size 
        cex.lab = 2) # Increase axes titles size) 
dev.off() # Close the device to save the file