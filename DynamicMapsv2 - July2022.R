
#Create dynamic maps for spatiotemporal distribution of floods across Central Java, Indonesia
#Breanne K Langlois doctoral dissertation research

#script written using the following examples:
  #https://conservancy.umn.edu/bitstream/handle/11299/220339/time-maps-tutorial-v2.html?sequence=3&isAllowed=y#example-generating-a-simple-animated-map
  #Meg Hartwick cholera and conflict - Yemen Time Series: https://github.com/meghartwick

library(ggplot2)
library(gganimate)
library(gifski)
library(maps)
library(sf)
library(dplyr)
library(tidyverse)


#set working directory
setwd("C:/Users/BLANGL01/Box/School - NEDS PhD/Dissertation Research - Working Folder/Data/Dynamic maps")

#download and read DFO shape file
  ## note: shapefiles (*.shp) are dependent on the presence of other file types
indonesia_l1 <- st_read('idn_admbnda_adm1_bps_20200401.shp')   #indonesia admin level 1 (province)
dfo_archive <- st_read('FloodArchive_Selection.shp')     #DFO flood archive in shapefile format
    #both are WGS 84 coordinate system

#create month and year variables from flood start date
    # create month variable from began date
    dfo_archive$month <- format(dfo_archive$BEGAN,"%B")

   # create year variable from began date
    dfo_archive$year <- format(dfo_archive$BEGAN,"%Y")
    dfo_archive$year <- as.integer(dfo_archive$year)
    
    # create combined month/year variable from began date
    dfo_archive$month_year <- format(dfo_archive$BEGAN,"%B %Y")

#create duration variable from began and ended dates
    dfo_archive$duration <- as.integer(difftime(dfo_archive$ENDED, dfo_archive$BEGAN, units = "days"))
    
    
##subset and simplify map data to improve speed of gif rendering
    ##**note: when using dplyr to select columns associated with a shape file, the shape file is automatically retained
    imap_l1 <- indonesia_l1 %>% select(ADM1_EN, ADM1_PCODE) 
    imap_l1 <- rmapshaper::ms_simplify(imap_l1)

    dfo_map <- dfo_archive %>% select(ID, LONG, LAT, BEGAN, SEVERITY, month, year, month_year, duration)
    dfo_map <- rmapshaper::ms_simplify(dfo_map)
    
    #basic plot of DFO archive data
    ggplot(data = dfo_map) +    #all events recorded by DFO
      geom_sf()
 
    

#create the basemap 
    #using data from maps package
#indonesia_map_data <- map_data("world", regions="indonesia") #reads in the map data
  
 # base_map <- ggplot(data = indonesia_map_data, mapping = aes(x = long, y = lat, group = group)) +  #now use ggplot to create the basemap of indonesia
  
    # geom_polygon(color = "black", fill = "white") +
    #coord_quickmap() +
    #theme_void() 
  #base_map
  
    #using the shapefile data
  base_map2 <- ggplot(data = imap_l1) +
    geom_sf(color = "black", fill = "white") +
    theme_void()
  base_map2


#add DFO data to the basemap  
  map_with_data <- base_map2 +
    geom_sf(data = dfo_map, aes(group=year))
  map_with_data
  
  map_with_data_zoom <- map_with_data +     #zoomed to central java
    coord_sf(xlim = c(105, 115),  ylim = c(-5, -10))
  map_with_data_zoom
  

#separate by year
  dfo_map1985 <- subset(dfo_map, year==1985)
  dfo_map1986 <- subset(dfo_map, year==1986)  
  dfo_map1987 <- subset(dfo_map, year==1987)  
  dfo_map1988 <- subset(dfo_map, year==1988)  
  dfo_map1989 <- subset(dfo_map, year==1989)  
  dfo_map1990 <- subset(dfo_map, year==1990)  
  dfo_map1991 <- subset(dfo_map, year==1991)  
  dfo_map1992 <- subset(dfo_map, year==1992)  
  dfo_map1993 <- subset(dfo_map, year==1993)  
  dfo_map1994 <- subset(dfo_map, year==1994)  
  dfo_map1995 <- subset(dfo_map, year==1995)  
  dfo_map1996 <- subset(dfo_map, year==1996)  
  dfo_map1997 <- subset(dfo_map, year==1997)  
  dfo_map1998 <- subset(dfo_map, year==1998)  
  dfo_map1999 <- subset(dfo_map, year==1999)  
  dfo_map2000 <- subset(dfo_map, year==2000)  
  dfo_map2001 <- subset(dfo_map, year==2001)  
  dfo_map2002 <- subset(dfo_map, year==2002)  
  dfo_map2003 <- subset(dfo_map, year==2003)  
  dfo_map2004 <- subset(dfo_map, year==2004)  
  dfo_map2005 <- subset(dfo_map, year==2005)  
  dfo_map2006 <- subset(dfo_map, year==2006)  
  dfo_map2007 <- subset(dfo_map, year==2007)  
  dfo_map2008 <- subset(dfo_map, year==2008)  
  dfo_map2009 <- subset(dfo_map, year==2009)  
  dfo_map2010 <- subset(dfo_map, year==2010)  
  dfo_map2011 <- subset(dfo_map, year==2011)  
  dfo_map2012 <- subset(dfo_map, year==2012)  
  dfo_map2013 <- subset(dfo_map, year==2013)  
  dfo_map2014 <- subset(dfo_map, year==2014)  
  dfo_map2015 <- subset(dfo_map, year==2015)  
  dfo_map2016 <- subset(dfo_map, year==2016)  
  dfo_map2017 <- subset(dfo_map, year==2017)  
  dfo_map2018 <- subset(dfo_map, year==2018)  
  dfo_map2019 <- subset(dfo_map, year==2019)  
  dfo_map2020 <- subset(dfo_map, year==2020)  
  dfo_map2021 <- subset(dfo_map, year==2021)  
  
  map_with_data_1985 <- base_map2 +
    geom_sf(data = dfo_map1985, aes(group=year))
  map_with_data_1985
  map_with_data_1986 <- base_map2 +
    geom_sf(data = dfo_map1986, aes(group=year))
  map_with_data_1986
  map_with_data_2020 <- base_map2 +
    geom_sf(data = dfo_map2020, aes(group=ID))
  map_with_data_2020
  

  
   
#highlight severity
  severity_colors <- c("tan1","darkorange2","orangered3")
  
  map_flood_severity_event <- base_map2 +
    geom_sf(data = dfo_map, aes(fill=SEVERITY, group=ID)) +
    scale_fill_gradientn(colours = severity_colors, breaks = c(1.00, 1.50, 2.00))
  map_flood_severity_event
  
  map_flood_severity <- base_map2 +
    geom_sf(data = dfo_map, aes(fill=SEVERITY, group=year)) +
    scale_fill_gradientn(colours = severity_colors, breaks = c(1.00, 1.50, 2.00))
  map_flood_severity
  
  map_flood_severity_zoom <- map_flood_severity +     #zoomed to central java
    coord_sf(xlim = c(105, 115),  ylim = c(-5, -10))
  map_flood_severity_zoom
  
  
  
#ANIMATE
  
    #by event
  
  dynamic_map_event <- map_flood_severity_event +
    transition_time(BEGAN) +
    ggtitle('{frame_time}',
            subtitle = 'Frame {frame} of {nframes}')
  
  animate(dynamic_map_event, nframes=80, fps=1)
  anim_save("DFO_floodevents_byevent.gif")
  
  
    
    #yearly
  dynamic_map <- map_flood_severity +
    transition_time(year) +
    ggtitle('Year: {frame_time}',
            subtitle = 'Frame {frame} of {nframes}')
 
  animate(dynamic_map, nframes = 36, fps=1)
  anim_save("DFO_floodevents_byyear.gif")
  
  dynamic_map_zoom <- map_flood_severity_zoom +
    transition_time(year) +
    ggtitle('Year: {frame_time}',
            subtitle = 'Frame {frame} of {nframes}')
  
  animate(dynamic_map_zoom, nframes = 36, fps=1)
  anim_save("DFO_floodevents_byyear_cj.gif")
  

  
  