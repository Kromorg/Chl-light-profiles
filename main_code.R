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

# Date extraction ####
dates <- substr(names(variable), 2, 11)
dates <- dates %>% parse_date_time("Ymd")

# Extract values from numeric model ####
sites.coords <- data.frame(Site = c('name1', 'name2'),
                           Longitude = c(coordinates),
                           Latitude = c(coordinates)) 
coords<- sites.coords[, 2:3]
coordinates(coords)<- ~Long + Lat

# Set coordinate reference system of multiband object
crs(coords)<- crs(variable)

# Extract mean values per month
mean.transp <-  raster:: extract(variable, coords,
                        fun = mean, na.rm = F)
as_tibble(mean.transp) %>% print(n = 5) # Preview values

rownames(mean.transp)<- sites.coords$Site # Set site names
rownames(mean.transp)