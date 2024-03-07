# Open libraries ####
pacman:: p_load(tidyverse, # Data wrangling
                ncdf4, # NetCDF file
                raster, # Raster objects and extract values
                sp, # Spatial data
                ggsci) # Profiles colors

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
ebes.chl <- mean.chl[2, ]

# Surface chlorophyll correction
ebes.produc <- data.frame(date = dates,
                        Site = c('El Bajo'),
                        Chlorophyll = ebes.chl*0.9)


# Interanual chlorophyll average value
round(mean(ebes.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, ebes.produc)


# Punta Lobos ####
lobos.chl <- mean.chl[3, ]

# Surface chlorophyll correction
lobos.produc <- data.frame(date = dates,
                        Site = c('Punta Lobos'),
                        Chlorophyll = lobos.chl*0.9)


# Interanual chlorophyll average value
round(mean(lobos.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, lobos.produc)


# La Ballena ####
ballena.chl <- mean.chl[4, ]

# Surface chlorophyll correction
ballena.produc <- data.frame(date = dates,
                        Site = c('La Ballena'),
                        Chlorophyll = ballena.chl*0.9)


# Interanual chlorophyll average value
round(mean(ballena.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, ballena.produc)


# El Gallo ####
gallo.chl <- mean.chl[5, ]

# Surface chlorophyll correction
gallo.produc <- data.frame(date = dates,
                        Site = c('El Gallo'),
                        Chlorophyll = gallo.chl*0.9)


# Interanual chlorophyll average value
round(mean(gallo.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, gallo.produc)


# Salvatierra ####
ship.chl <- mean.chl[6, ]

# Surface chlorophyll correction
ship.produc <- data.frame(date = dates,
                        Site = c('Salvatierra'),
                        Chlorophyll = ship.chl*0.9)


# Interanual chlorophyll average value
round(mean(ship.chl), 2)

# Add El Bajo values to the interanual base
interanual.produc <- rbind(interanual.produc, ship.produc)


# Remove objects ####
rm(ncfile, cmes.data, multi.chl, polygon.mean, polygon.sd,
dates, sites.coords, coords, mean.chl, islotes.chl,
ebes.chl, ebes.produc, lobos.chl,
lobos.produc, ballena.chl, ballena.produc, gallo.chl,
gallo.produc, ship.chl, ship.produc)


# Monthly summary at each site ####
monthly.summary <- interanual.produc %>%
        group_by(Site, month(date)) %>%
        summarise(Mean_chl = mean(Chlorophyll))
as_tibble(monthly.summary)


# Change numerical months to factors ####
colnames(monthly.summary)[2] <- 'Month'
monthly.summary$Month <- rep(month.name[], times = 6)
monthly.summary$Month<- factor(monthly.summary$Month,
                   levels = c('January', 'February', 'March',
                              'April', 'May', 'June', 'July',
                              'August', 'September', 'October',
                              'November', 'December'),
                   ordered = T)


# Chlorophyll profiles ####
# Los Islotes ####
# Cold season: February

z <- seq(from = 0, to = 100, by = 1)
Chl.o <- 0.07
h <- 30.2
thick <- 25.2
Z.m <- monthly.summary %>% filter(Month == 'February' &
                              Site == 'Los Islotes') %>%
                dplyr:: select(Mean_chl) %>%
        mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                           (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
feb <- data.frame(Depth = z,
                 Month = 'February',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                   exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Warm season: September
Chl.o<- 0.1
h<- 79.4
thick<- 27.4
Z.m<- monthly.summary %>% filter(Month == 'September' &
                              Site == 'Los Islotes') %>%
                dplyr:: select(Mean_chl) %>%
         mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                                (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
sept<- data.frame(Depth = z,
                 Month = 'September',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                        exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Merge and create graphical object
chl.islotes<-  rbind(feb, sept)
cols.pal<- pal_lancet()(2)

graph.islotes<- ggplot()+
  geom_jitter(data = chl.islotes,
              aes(x = Chlorophyll, y = Depth, fill = Month),
              shape = 21, size = 3, alpha = 0.4,
              show.legend = F)+
  labs(y = 'Depth (m)',
       x = expression(Chlorophyll~(mg~m^{'-3'})),
       subtitle = c('Los Islotes'))+
  scale_y_reverse()+ scale_fill_lancet()+
  geom_hline(yintercept = c(18, 35), # 1% of light
             colour = cols.pal,
             linetype = c('dotted', 'dotdash'))+
  scale_x_discrete(position = 'top')+
  scale_x_continuous(limits = c (0, 8), position = 'top')+
  theme_bw(base_size = 13)+
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 17))

graph.islotes


# El Bajo ####
# Cold season: February

z <- seq(from = 0, to = 100, by = 1)
Chl.o <- 0.07
h <- 30.2
thick <- 25.2
Z.m <- monthly.summary %>% filter(Month == 'February' &
                              Site == 'El Bajo') %>%
                dplyr:: select(Mean_chl) %>%
        mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                           (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
feb <- data.frame(Depth = z,
                 Month = 'February',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                   exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Warm season: September
Chl.o<- 0.1
h<- 79.4
thick<- 27.4
Z.m<- monthly.summary %>% filter(Month == 'September' &
                              Site == 'El Bajo') %>%
                dplyr:: select(Mean_chl) %>%
         mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                                (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
sept<- data.frame(Depth = z,
                 Month = 'September',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                        exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Merge and create graphical object
chl.ebes<-  rbind(feb, sept)

graph.ebes<- ggplot()+
  geom_jitter(data = chl.ebes,
              aes(x = Chlorophyll, y = Depth, fill = Month),
              shape = 21, size = 3, alpha = 0.4,
              show.legend = F)+
  labs(y = NULL,
       x = expression(Chlorophyll~(mg~m^{'-3'})),
       subtitle = c('El Bajo'))+
  scale_y_reverse()+ scale_fill_lancet()+
  geom_hline(yintercept = c(27, 42), # 1% of light
             colour = cols.pal,
             linetype = c('dotted', 'dotdash'))+
  scale_x_discrete(position = 'top')+
  scale_x_continuous(limits = c (0, 8), position = 'top')+
  theme_bw(base_size = 13)+
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 17))

graph.ebes


# Punta Lobos ####
# Cold season: February

z <- seq(from = 0, to = 100, by = 1)
Chl.o <- 0.07
h <- 30.2
thick <- 25.2
Z.m <- monthly.summary %>% filter(Month == 'February' &
                              Site == 'Punta Lobos') %>%
                dplyr:: select(Mean_chl) %>%
        mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                           (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
feb <- data.frame(Depth = z,
                 Month = 'February',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                   exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Warm season: September
Chl.o<- 0.1
h<- 79.4
thick<- 27.4
Z.m<- monthly.summary %>% filter(Month == 'September' &
                              Site == 'Punta Lobos') %>%
                dplyr:: select(Mean_chl) %>%
         mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                                (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
sept<- data.frame(Depth = z,
                 Month = 'September',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                        exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Merge and create graphical object
chl.lobos<-  rbind(feb, sept)

graph.lobos<- ggplot()+
  geom_jitter(data = chl.lobos,
              aes(x = Chlorophyll, y = Depth, fill = Month),
              shape = 21, size = 3, alpha = 0.4,
              show.legend = F)+
  labs(y = NULL,
       x = expression(Chlorophyll~(mg~m^{'-3'})),
       subtitle = c('Punta Lobos'))+
  scale_y_reverse()+ scale_fill_lancet()+
  geom_hline(yintercept = c(25, 39), # 1% of light
             colour = cols.pal,
             linetype = c('dotted', 'dotdash'))+
  scale_x_discrete(position = 'top')+
  scale_x_continuous(limits = c (0, 8), position = 'top')+
  theme_bw(base_size = 13)+
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 17))

graph.lobos


# La Ballena ####
# Cold season: February

z <- seq(from = 0, to = 100, by = 1)
Chl.o <- 0.07
h <- 30.2
thick <- 25.2
Z.m <- monthly.summary %>% filter(Month == 'February' &
                              Site == 'La Ballena') %>%
                dplyr:: select(Mean_chl) %>%
        mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                           (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
feb <- data.frame(Depth = z,
                 Month = 'February',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                   exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Warm season: September
Chl.o<- 0.1
h<- 79.4
thick<- 27.4
Z.m<- monthly.summary %>% filter(Month == 'September' &
                              Site == 'La Ballena') %>%
                dplyr:: select(Mean_chl) %>%
         mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                                (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
sept<- data.frame(Depth = z,
                 Month = 'September',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                        exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Merge and create graphical object
chl.ballena<-  rbind(feb, sept)

graph.ballena<- ggplot()+
  geom_jitter(data = chl.ballena,
              aes(x = Chlorophyll, y = Depth, fill = Month),
              shape = 21, size = 3, alpha = 0.4,
              show.legend = F)+
  labs(y = 'Depth (m)',
       x = NULL,
       subtitle = c('La Ballena'))+
  scale_y_reverse()+ scale_fill_lancet()+
  geom_hline(yintercept = c(18, 35), # 1% of light
             colour = cols.pal,
             linetype = c('dotted', 'dotdash'))+
  scale_x_discrete(position = 'top')+
  scale_x_continuous(limits = c (0, 8), position = 'top')+
  theme_bw(base_size = 13)+
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 17))

graph.ballena


# El Gallo ####
# Cold season: February

z <- seq(from = 0, to = 100, by = 1)
Chl.o <- 0.07
h <- 30.2
thick <- 25.2
Z.m <- monthly.summary %>% filter(Month == 'February' &
                              Site == 'El Gallo') %>%
                dplyr:: select(Mean_chl) %>%
        mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                           (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
feb <- data.frame(Depth = z,
                 Month = 'February',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                   exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Warm season: September
Chl.o<- 0.1
h<- 79.4
thick<- 27.4
Z.m<- monthly.summary %>% filter(Month == 'September' &
                              Site == 'El Gallo') %>%
                dplyr:: select(Mean_chl) %>%
         mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                                (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
sept<- data.frame(Depth = z,
                 Month = 'September',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                        exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Merge and create graphical object
chl.gallo<-  rbind(feb, sept)

graph.gallo<- ggplot()+
  geom_jitter(data = chl.gallo,
              aes(x = Chlorophyll, y = Depth, fill = Month),
              shape = 21, size = 3, alpha = 0.4,
              show.legend = F)+
  labs(y = NULL,
       x = NULL,
       subtitle = c('El Gallo'))+
  scale_y_reverse()+ scale_fill_lancet()+
  geom_hline(yintercept = c(18, 35), # 1% of light
             colour = cols.pal,
             linetype = c('dotted', 'dotdash'))+
  scale_x_discrete(position = 'top')+
  scale_x_continuous(limits = c (0, 8), position = 'top')+
  theme_bw(base_size = 13)+
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 17))

graph.gallo


# Salvatierra ####
# Cold season: February

z <- seq(from = 0, to = 100, by = 1)
Chl.o <- 0.07
h <- 30.2
thick <- 25.2
Z.m <- monthly.summary %>% filter(Month == 'February' &
                              Site == 'Salvatierra') %>%
                dplyr:: select(Mean_chl) %>%
        mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                           (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
feb <- data.frame(Depth = z,
                 Month = 'February',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                   exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Warm season: September
Chl.o<- 0.1
h<- 79.4
thick<- 27.4
Z.m<- monthly.summary %>% filter(Month == 'September' &
                              Site == 'Salvatierra') %>%
                dplyr:: select(Mean_chl) %>%
         mutate(Z.m = thick* (abs(2* log(h / ((thick*(2 * pi)^0.5)*
                                (.[[2]] - Chl.o))))^0.5)) %>%
        .[[3]]
sept<- data.frame(Depth = z,
                 Month = 'September',
                 Chlorophyll = Chl.o + ((h/thick*((2*pi)^0.5)) *
                        exp(-((z - Z.m)^2/ (2 * thick^2)))))

# Merge and create graphical object
chl.ship<-  rbind(feb, sept)

graph.ship<- ggplot()+
  geom_jitter(data = chl.ship,
              aes(x = Chlorophyll, y = Depth, fill = Month),
              shape = 21, size = 3, alpha = 0.4,
              show.legend = F)+
  labs(y = NULL,
       x = NULL,
       subtitle = c('Salvatierra'))+
  scale_y_reverse()+ scale_fill_lancet()+
  geom_hline(yintercept = c(18, 35), # 1% of light
             colour = cols.pal,
             linetype = c('dotted', 'dotdash'))+
  scale_x_discrete(position = 'top')+
  scale_x_continuous(limits = c (0, 8), position = 'top')+
  theme_bw(base_size = 13)+
  theme(panel.grid = element_blank(),
        axis.line = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 17))

graph.ship


# Final graph ####
final <- gridExtra::grid.arrange(graph.islotes, graph.ebes, graph.lobos,
                        graph.ballena, graph.gallo, graph.ship,
                        ncol = 3, nrow = 2)
ggsave('Chlorophyll profiles.jpeg', plot = final, dpi = 320,
          width = 3000, height = 2500, units = 'px')
