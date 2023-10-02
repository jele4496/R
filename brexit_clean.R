library(sf)
library(dplyr)

setwd('~/Documents/school/spring_2022/geog3023/Labs/Lab10/')
votes <- read.csv('EU-referendum-result-data.csv')
regions <- read_sf('./district_boundaries_raw.shp')
brexit <- merge(votes,regions, by.x="Area_Code",by.y="lad16cd")
brexit_small <- brexit %>% select(c(Area_Code, Region, Area, Electorate, Pct_Turnout, Pct_Remain, Pct_Leave, Pct_Rejected, geometry))
write_sf(brexit_small, './brexit.geojson')