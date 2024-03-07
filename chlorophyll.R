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
ncfile<- 'cmems_obs-oc_glo_bgc-plankton_my_l4-multi-4km_P1M_1693680905216.nc'

# Open NetCDF file
cmes.data <- nc_open(ncfile)

# File information
print(cmes.data)
attributes(cmes.data$var)

# Multiband ####
# Raster object using chlorophyll data
multi.chl <- brick(ncfile, varname = 'CHL')

# Analysis using the raster object ####
# Statistical summary
# Mean and standard deviation estimates
polygon.mean <- calc(multi.chl, fun = mean)
polygon.sd <- calc(multi.chl, fun = sd)

# Plot multiband data
plot(polygon.mean, main = "Average Chlorophyll")
plot(polygon.sd, main = "Standard deviation Chlorophyll")

# Date extraction ####
dates <- substr(names(multi.chl), 2, 11)
dates <- dates %>% parse_date_time("Ymd")

# Extract values from numeric model ####
sites.coords <- data.frame(Coast = rep(c('East', 'West'), each = 3), 
        Site = c('Los Islotes Este', 'El Bajo', 'Punta Lobos',
                 'La Ballena', 'El Gallo', 'Salvatierra'),
        Latitude = c(24.59989, 24.70392, 24.47584,
                        24.486929, 24.467158, 24.386501),
        Longitude = c(-110.388601, -110.301147, -110.28774,
                        -110.405131, -110.386226, -110.312299),
        stringsAsFactors = T)
coords <- sites.coords[, 3:4]
coordinates(coords)<- ~Longitude + Latitude

# Set coordinate reference system of multiband object
crs(coords) <- crs(multi.chl)

# Extract mean values per month
mean.chl <-  raster:: extract(multi.chl, coords,
                        fun = mean, na.rm = F)
as_tibble(mean.chl) %>% print(n = 5) # Preview values

rownames(mean.chl) <- sites.coords$Site # Set site names
rownames(mean.chl)

# Analysis per site ####
# Los Islotes ####

islotes.chl <- mean.chl[1, ]

# Surface chlorophyll correction
interanual.produc <- data.frame(date = dates,
                        Site = c('Los Islotes'),
                        Chlorophyll = islotes.chl*0.9)


# Interanual chlorophyll average value
round(mean(islotes.chl), 2)


# El Bajo ####
ebes.chl <- mean.chl[1, ]

# Surface chlorophyll correction
ebes.produc <- data.frame(date = dates,
                        Site = c('El Bajo'),
                        Chlorophyll = ebes.chl*0.9)


# Interanual chlorophyll average value
round(mean(ebes.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, ebes.produc)


# Punta Lobos ####
lobos.chl <- mean.chl[1, ]

# Surface chlorophyll correction
lobos.produc <- data.frame(date = dates,
                        Site = c('Punta Lobos'),
                        Chlorophyll = lobos.chl*0.9)


# Interanual chlorophyll average value
round(mean(ebes.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, lobos.produc)


# La Ballena ####
ballena.chl <- mean.chl[1, ]

# Surface chlorophyll correction
ballena.produc <- data.frame(date = dates,
                        Site = c('La Ballena'),
                        Chlorophyll = ballena.chl*0.9)


# Interanual chlorophyll average value
round(mean(ebes.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, ballena.produc)


# El Gallo ####
gallo.chl <- mean.chl[1, ]

# Surface chlorophyll correction
gallo.produc <- data.frame(date = dates,
                        Site = c('El Gallo'),
                        Chlorophyll = gallo.chl*0.9)


# Interanual chlorophyll average value
round(mean(ebes.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, gallo.produc)


# Salvatierra ####
ship.chl <- mean.chl[1, ]

# Surface chlorophyll correction
ship.produc <- data.frame(date = dates,
                        Site = c('Salvatierra'),
                        Chlorophyll = ship.chl*0.9)


# Interanual chlorophyll average value
round(mean(ebes.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, ship.produc)


# Remove objects ####
rm(ncfile, cmes.data, multi.chl, polygon.mean, polygon.sd,
dates, sites.coords, coords, mean.chl, islotes.chl,
islotes.chl, ebes.chl, ebes.chl, lobos.chl,
lobos.chl, ballena.chl, ballena.chl, gallo.chl,
gallo.chl, ship.chl, ship.chl)