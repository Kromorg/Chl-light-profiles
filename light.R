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
ncfile<- 'cmems_obs-oc_glo_bgc-transp_my_l4-multi-4km_P1M_1693461359433.nc'

# Open NetCDF file
cmes_data <- nc_open(ncfile)

# File information
print(cmes_data)
attributes(cmes_data$var)

# Multiband ####
# Raster object using water transparency data
multi_transp <- brick(ncfile, varname = 'KD490')

# Analysis using the raster object ####
# Statistical summary
# Mean and standard deviation estimates
polygon_mean <- calc(multi_transp, fun = mean)
polygon_sd <- calc(multi_transp, fun = sd)

# Plot multiband data
plot(polygon_mean, main = "Average Kd490")
plot(polygon_sd, main = "Standard deviation Kd490")

# Date extraction ####
dates <- substr(names(multi_transp), 2, 11)
dates <- dates %>% parse_date_time("Ymd")

# Extract values from numeric model ####
sites.coords <- data.frame(Coast = rep(c('East', 'West'), each = 3), 
        Site = c('Los Islotes Este', 'El Bajo', 'Punta Lobos',
                 'La Ballena', 'El Gallo', 'Salvatierra'),
        Longitude = c(24.59, 24.70, 24.47, 24.48, 24.46, 24.38),
        Latitude = c(-110.38, -110.30, -110.28,
                     -110.40, -110.38, -110.31)) 
coords<- sites.coords[, 3:4]
coordinates(coords)<- ~Longitude + Latitude

# Set coordinate reference system of multiband object
crs(coords)<- crs(variable)

# Extract mean values per month
mean.transp <-  raster:: extract(variable, coords,
                        fun = mean, na.rm = F)
as_tibble(mean.transp) %>% print(n = 5) # Preview values

rownames(mean.transp)<- sites.coords$Site # Set site names
rownames(mean.transp)