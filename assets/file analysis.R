library(tidyverse)
library(lubridate)
library(sf)

# Set working directory and read in crime dataset
setwd("/Users/armvg/Desktop/GIS/SeattleAlleyCrimes/assets")
crime <- read.csv("SPDCrime.csv")

# Filter out data except for 2023 entries
crime_2023 <- crime %>%
  mutate(Report.DateTime = as.POSIXct(Report.DateTime, format = "%m/%d/%Y %H:%M", tz = "UTC")) %>%
  filter(year(Report.DateTime) == 2023)

# Remove rows where the latitude and longitude are 0
crime_filtered <- crime_2023 %>%
  filter(Latitude != 0 | Longitude != 0)

# Create Simple Features Dataframe
crime_sf <- st_as_sf(crime_filtered, coords = c("Longitude", "Latitude"))

# Define the bounding box polygon for alley GeoJSON file boundaries
bbox_polygon <- st_polygon(list(cbind(c(-122.36688547657454, -122.36688547657454, -122.3007053422532, -122.3007053422532, -122.36688547657454),
                                      c(47.62936251919575, 47.593593092415574, 47.593593092415574, 47.62936251919575, 47.62936251919575))))

# Filter points within the bounding box polygon
crime_within_bbox <- st_within(crime_sf, bbox_polygon)

# Create a new data frame with filtered points
crime_within_bbox_df <- crime_sf[as.logical(crime_within_bbox), ]

# Write to a new GeoJSON File
st_write(crime_within_bbox_df, "/Users/armvg/Desktop/GIS/SeattleAlleyCrimes/assets/SPDCrime2023Filtered.geojson")
