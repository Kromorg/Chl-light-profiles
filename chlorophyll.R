# Open libraries ####
pacman:: p_load(tidyverse, # Data wrangling
                ncdf4, # NetCDF file
                raster, # Raster objects and extract values
                gridExtra) # Multiple plots

# Clean console ####
rm(list = ls())
shell('cls')

# NetCDF files ####
# Object of the file that will be used
ncfile<- 'cmems_obs-oc_glo_bgc-plankton_my_l4-multi-4km_P1M_1693680905216.nc'

# Open NetCDF file
cmes_data <- nc_open(ncfile)

# File information
print(cmes_data)
attributes(cmes_data$var)

# Multiband ####
# Raster object using chlorophyll data
multi_chl <- brick(ncfile, varname = 'CHL')

# Analysis using the raster object ####
# Statistical summary
# Mean and standard deviation estimates
polygon_mean <- calc(multi_chl, fun = mean)
polygon_sd <- calc(multi_chl, fun = sd)

# Plot multiband data
plot(polygon_mean, main = "Average Chlorophyll")
plot(polygon_sd, main = "Standard deviation Chlorophyll")