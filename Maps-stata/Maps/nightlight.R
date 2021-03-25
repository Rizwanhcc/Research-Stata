#=====Night Light Data=====##
#https://ngdc.noaa.gov/eog/dmsp/downloadV4composites.html
#https://commercedataservice.github.io/tutorial_viirs_part1/
#http://economics.mit.edu/files/8945
#https://github.com/walshc/nightlights


devtools::install_github("walshc/nightlights")
require(nightlights)
# Download, extract and load and example shapefile to work with (US counties):
download.file("ftp://ftp2.census.gov/geo/tiger/TIGER2015/COUSUB/tl_2015_25_cousub.zip",
              destfile = "tl_2015_25_cousub.zip")

unzip("tl_2015_25_cousub.zip")
shp <- rgdal::readOGR(".", "tl_2015_25_cousub")

# Download and extract some night lights data to a directory "night-lights":
downloadNightLights(years = 2012:2013, directory = "night-lights")

# By default, the function gets the sum of night lights within the regions:
nl.sums <- extractNightLights(directory = "night-lights", shp)

# You can specificy other statistics to get, e.g. the mean & standard deviation:
nl.mean.sd <- extractNightLights(directory = "night-lights", shp,
                                 stats = c("mean", "sd"))

require(maps)
library(ggplot2)
pakistan = map_data('world', region = 'Pakistan')

ggplot(pakistan.adm2.df, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = 'green', colour = 'black')


pakmap <- ggplot(newpak, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = 'gray', colour = 'black')


##This will make a plot for pakistan by including jnk region as well
library(dplyr)
library(raster)
library(sf)
library(tidyverse)
library(ggrepel)
install.packages("devtools")

devtools::install_github("tidyverse/ggplot2", force = TRUE)
library(ggplot2)
# map of Pakistan, admin level 3.
pak <- getData("GADM",country="PAK",level=3) 

pak <- st_as_sf(pak) %>% 
  mutate(
    lon = map_dbl(geometry, ~st_centroid(.x)[[1]]),
    lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

ggplot(pak) + geom_sf() + geom_text(aes(label = NAME_3, x = lon, y = lat), size = 1.5)

##Now try to map kashmir
ind <- getData("GADM",country="IND",level=3) 

ind <- st_as_sf(ind) %>% 
  mutate(
    lon = map_dbl(geometry, ~st_centroid(.x)[[1]]),
    lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

jnk <- subset(ind, OBJECTID >= 641 & OBJECTID <= 664 )
plot(jnk)

newpak <- rbind(pak, jnk)


regionalValues <- runif(165)  # Simulate a value for each region between 0 and 1
plot(newpak, col = gray(regionalValues), border = 0)
pakistan.adm2.df <- fortify(pak, region = "NAME_2")


ggplot(newpak) + geom_sf(aes(fill = regionalValues)) + geom_text(aes(label = NAME_3, x = lon, y = lat), size = 2)

##new version of the pak map
library(raster)
library(sf)
library(tidyverse)
library(ggplot2)
install.packages("RColorBrewer")
library(RColorBrewer)

# downlaod PAK data and convert to sf
pak <- getData("GADM",country="PAK",level=3) %>% 
  st_as_sf()

# download IND data, convert to sf, filter out 
# desired area, and add NAME_3 label
jnk <- getData("GADM",country="IND",level=3) %>%
  st_as_sf() %>%
  filter(OBJECTID %>% between(641, 664)) %>%
  group_by(NAME_0) %>%
  summarize() %>%
  mutate(NAME_3 = "Jammu n Kashmir")

regionalValues <- runif(142)  # Simulate a value for each region between 0 and 1

# combine the two dataframes, find the center for each
# region, and the plot with ggplot
pak %>% 
  select(NAME_0, NAME_3, geometry) %>%
  rbind(jnk) %>% 
  mutate(
  lon = map_dbl(geometry, ~st_centroid(.x)[[1]]),
  lat = map_dbl(geometry, ~st_centroid(.x)[[2]])
  ) %>%
  ggplot() + 
  geom_sf(aes(fill = regionalValues)) +
  geom_text(aes(label = NAME_3, x = lon, y = lat), size = 2) +
  scale_fill_distiller(palette = "Spectral")

head(regionalValues, n = 142)
#Now add poverty data
#https://iknomics.wordpress.com/2011/04/12/district-level-poverty-in-pakistan/
#https://www.sdpi.org/publications/files/Clustered%20Deprivation-district%20profile%20of%20poverty%20in%20pakistan.pdf