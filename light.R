# Open libraries ####
pacman:: p_load(tidyverse, # Data wrangling
                ncdf4, # NetCDF file
                raster, # Raster objects and extract values
                sp) # Spatial data

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
        Site = c('Los Islotes', 'El Bajo', 'Punta Lobos',
                 'La Ballena', 'El Gallo', 'Salvatierra'),
        Latitude = c(24.59989, 24.70392, 24.47584,
                        24.486929, 24.467158, 24.386501),
        Longitude = c(-110.388601, -110.301147, -110.28774,
                        -110.405131, -110.386226, -110.312299),
                stringsAsFactors = T)
coords<- sites.coords[, 3:4]
coordinates(coords)<- ~Longitude + Latitude

# Set coordinate reference system of multiband object
crs(coords)<- crs(multi_transp)

# Extract mean values per month
mean.transp <-  raster:: extract(multi_transp, coords,
                        fun = mean, na.rm = F)
as_tibble(mean.transp) %>% print(n = 5) # Preview values

rownames(mean.transp)<- sites.coords$Site # Set site names
rownames(mean.transp)


# Analysis per site ####
# Los Islotes ####

islotes.kd490 <- mean.transp[1, ]
islotes.transp <- data.frame(date = dates,
                        Site = c('Los Islotes'),
                        Transparency = c(islotes.kd490))

# Interanual Kd490 average value
round(mean(islotes.transp$Transparency), 2)

# Transform Kd490 to KdPAR (light attenuation coefficient)
interanual.kdpar <- data.frame(islotes.transp,
                           k = 0.0864+
                             (0.884*islotes.transp$Transparency)-
                             (0.00137*islotes.transp$Transparency^-1))



