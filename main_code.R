# Open libraries ####
pacman:: p_load(tidyverse, # Data wrangling
                ncdf4, # NetCDF file
                raster, # Raster objects and extract values
                gridExtra) # Multiple plots

# Clean console ####
rm(list = ls())
shell('cls')

# NetCDF files ####
# Object with the name of the file that will be used
ncfile<- 'file name.nc'

# Open NetCDF file
cmes_data <- nc_open(ncfile)

# File information
print(cmes_data)
attributes(cmes_data$var)

# Multiband ####
# Multiband data extraction using NetCDF object
variable <- brick(ncfile, varname = 'variable of interest')

# Analysis using the raster object ####
# Statistical summary
# Mean and standard deviation estimates
polygon_mean <- calc(variable, fun = mean)
polygon_sd <- calc(variable, fun = sd)

# Plot multiband data
plot(polygon_mean, main = "Average variable")
plot(polygon_sd, main = "Standard deviation variable")