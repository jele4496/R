lab 5 Demo
========================================================
author: Behzad Vahedi
date: 
autosize: true

Learning Goals for Lab 5
========================================================

- Understand how to process raster data
- Understand how to make maps with ggmap
- Understand what constitutes a point process
- Detect and create point-pattern density surfaces
- Identify how points are clustered in space (uniform, random, clustered).


Fun with rasters
=======================

SRTM is the DEMs created from the space shuttle mission a while back


```r
library(raster)
library(tidyverse)
library(viridis)
x<-getData("SRTM", lat=40.008115221229446, lon=-105.27416298041831)

plot(x)
```

![plot of chunk unnamed-chunk-1](lab_4_demo-figure/unnamed-chunk-1-1.png)

Key detail when working with rasters
====================

36,000,000 cells... 


```r
x
```

```
class      : RasterLayer 
dimensions : 6000, 6000, 3.6e+07  (nrow, ncol, ncell)
resolution : 0.0008333333, 0.0008333333  (x, y)
extent     : -110, -105, 40, 45  (xmin, xmax, ymin, ymax)
crs        : +proj=longlat +datum=WGS84 +no_defs 
source     : srtm_15_04.tif 
names      : srtm_15_04 
```



first, we'll clip it
======


```r
extent<-c(range(-105,-105.5), range(40,40.5))

boulder_area<-x %>%
  raster::crop(y=extent)
```


lets ggplot it
===========

```r
boulder_area%>%
  as.data.frame(xy=TRUE) %>%
  ggplot() +
  geom_raster(aes(x=x,y=y,fill=srtm_15_04))+
  scale_fill_viridis() +
  geom_point(aes(x=-105.27416298041831, y=40.008115221229446), shape=8, color="orange") +
  theme_minimal()
```

![plot of chunk unnamed-chunk-4](lab_4_demo-figure/unnamed-chunk-4-1.png)

Maybe we want to reclassify?
===============

the best way to reclassify a raster is not with the reclassify function! It's via the following.
first let's check the values.


```r
hist(raster::getValues(boulder_area))
```

![plot of chunk unnamed-chunk-5](lab_4_demo-figure/unnamed-chunk-5-1.png)



lowlands, mountains, above treeline
==================================



```r
rcl<- boulder_area
rcl[rcl<2000] <- 1
rcl[rcl>=2000 & rcl < 2500] <- 2
rcl[rcl>=2500] <- 3
```

Let's see how that looks
====================


```r
rcl %>%
  as.data.frame(xy=TRUE) %>%
  mutate(srtm_15_04 = as.factor(srtm_15_04))%>%
  ggplot() +
  geom_raster(aes(x=x,y=y,fill=srtm_15_04))+
  geom_point(aes(x=-105.27416298041831, y=40.008115221229446), shape=8, 
             color="orange")
```

![plot of chunk unnamed-chunk-7](lab_4_demo-figure/unnamed-chunk-7-1.png)

How do we get more informative labels?
====================
a lookup table, a.k.a. a named vector, is one option


```r
lut_labs <- c("1"="lowlands",
              "2"="montane",
              "3"="highlands")

rcl %>%
  as.data.frame(xy=TRUE) %>%
  mutate(srtm_15_04 = lut_labs[as.character(srtm_15_04)])%>%
  ggplot() +
  geom_raster(aes(x=x,y=y,fill=srtm_15_04))+
  geom_point(aes(x=-105.27416298041831, y=40.008115221229446), shape=8, color="orange")
```

![plot of chunk unnamed-chunk-8](lab_4_demo-figure/unnamed-chunk-8-1.png)

How do we get more informative labels?
====================
defining the labels within the factor column


```r
rcl %>%
  as.data.frame(xy=TRUE) %>%
  mutate(srtm_15_04 = factor(srtm_15_04, levels = c(1,2,3),
                             labels = c("lowlands", "montane", "alpine")))%>%
  ggplot() +
  geom_raster(aes(x=x,y=y,fill=srtm_15_04))+
  geom_point(aes(x=-105.27416298041831, y=40.008115221229446), shape=8, color="orange")
```

![plot of chunk unnamed-chunk-9](lab_4_demo-figure/unnamed-chunk-9-1.png)

