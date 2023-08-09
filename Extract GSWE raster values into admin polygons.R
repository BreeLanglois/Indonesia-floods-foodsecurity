#Extract raster values into administrative boundary polygons for linking to Stata dataset
#Breanne K Langlois doctoral dissertation research
#December, 2022


#set to data directory
setwd("C:/Users/BLANGL01/Box/School - NEDS PhD/Dissertation Research - Working Folder/Data/")


# load packages
library(sf) # Simple Features for R
library(raster)
library(ggplot2) # Create Elegant Data Visualisations Using the Grammar of Graphics
library(dplyr) # A Grammar of Data Manipulation
library(sp)
library(exactextractr) #Fast Extraction from Raster Datasets using Polygons (https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf)
library(haven) #to write stata files

### STEP 1: LOAD RASTER AND POLYGON DATA ###

# load rasters (NOTE: central java cuts across 2 grids)

  #water occurrence
gswe_occurrence100E <- raster(x = "Flood data/raw/From Global Surface Water Explorer/1984-2015/occurrence_100E_0N.tif")
  crs(gswe_occurrence100E) #view coordinate reference system
  plot(gswe_occurrence100E) #plot data
gswe_occurrence110E <- raster(x = "Flood data/raw/From Global Surface Water Explorer/1984-2015/occurrence_110E_0N.tif")
  crs(gswe_occurrence110E) #view coordinate reference system
  plot(gswe_occurrence110E) #plot data

  #recurrence 
gswe_recurrence100E <- raster(x = "Flood data/raw/From Global Surface Water Explorer/1984-2015/recurrence_100E_0N.tif")
  crs(gswe_recurrence100E) #view coordinate reference system
  plot(gswe_recurrence100E) #plot data
gswe_recurrence110E <- raster(x = "Flood data/raw/From Global Surface Water Explorer/1984-2015/recurrence_110E_0N.tif")
  crs(gswe_recurrence110E) #view coordinate reference system
  plot(gswe_recurrence110E) #plot data
  
  #occurrence change intensity
gswe_change100E <- raster(x = "Flood data/raw/From Global Surface Water Explorer/1984-2015/change_100E_0N.tif")
  crs(gswe_change100E) #view coordinate reference system
  plot(gswe_change100E) #plot data
gswe_change110E <- raster(x = "Flood data/raw/From Global Surface Water Explorer/1984-2015/change_110E_0N.tif")
  crs(gswe_change110E) #view coordinate reference system
  plot(gswe_change110E) #plot data
  

  #mosaic the raster tiles
  
    #water occurrence 
  gswe_occurrence_mosaic <- mosaic(gswe_occurrence100E, gswe_occurrence110E, fun="max")
    extent(gswe_occurrence_mosaic)
    plot(gswe_occurrence_mosaic)
  
    #recurrence
  gswe_recurrence_mosaic <- mosaic(gswe_recurrence100E, gswe_recurrence110E, fun="max")
    extent(gswe_recurrence_mosaic)
    plot(gswe_recurrence_mosaic)
  
    #occurrence change intensity
  gswe_change_mosaic <- mosaic(gswe_change100E, gswe_change110E, fun="max")
    extent(gswe_change_mosaic)
    plot(gswe_change_mosaic)
    
  
# indonesia administrative boundary polygon data
  # use sf package to read in shape file
indonesia_l1 <- st_read("Indonesia administrative boundaries/idn_adm_bps_20200401_shp/idn_admbnda_adm1_bps_20200401.shp")   #indonesia admin level 1 (province)
indonesia_l3 <- st_read("Indonesia administrative boundaries/idn_adm_bps_20200401_shp/idn_admbnda_adm3_bps_20200401.shp")   #indonesia admin level 3 (district)

  ##subset data to Central Java 
  indonesia_cj_l1 <- indonesia_l1[indonesia_l1$ADM1_EN == 'Jawa Tengah',]
  indonesia_cj_l3 <- indonesia_l3[indonesia_l3$ADM1_EN == 'Jawa Tengah',]

  #view maps
    #basic plot of indonesia with admin 1 levels (provinces)
  ggplot(data = indonesia_l1) +
    geom_sf()
    #basic plot of central java (province level)
  ggplot(data = indonesia_cj_l1) +
    geom_sf()
    #basic plot of central java with districts
  ggplot(data = indonesia_cj_l3) +
    geom_sf()



### STEP 2: MASK AND CROP THE RASTER LAYERS ###

  #water occurrence
gswe_occurrence_cropped <- crop(gswe_occurrence_mosaic, extent(indonesia_cj_l1))
gswe_occurrence_masked <- mask(gswe_occurrence_cropped, indonesia_cj_l1)
  ## Check that it worked
  plot(gswe_occurrence_masked) #data values range from 0-100, these are discrete values w/0 = Not Water and 100 = 100% occurrence (i.e. permanent water bodies)
  plot(indonesia_cj_l1, add=TRUE, lwd=2)
  
  #recurrence
gswe_recurrence_cropped <- crop(gswe_recurrence_mosaic, extent(indonesia_cj_l1))
gswe_recurrence_masked <- mask(gswe_recurrence_cropped, indonesia_cj_l1)
  ## Check that it worked
  plot(gswe_recurrence_masked) #data values range from 0-100, these are discrete values w/0 = Not Water and 100 = 100% recurrence
  plot(indonesia_cj_l1, add=TRUE, lwd=2)

  #occurrence change intensity
gswe_change_cropped <- crop(gswe_change_mosaic, extent(indonesia_cj_l1))
gswe_change_masked <- mask(gswe_change_cropped, indonesia_cj_l1)
  ## Check that it worked
  plot(gswe_change_masked) #data values range from 0- ~250, 0=-100% loss of occurrence, 100=No change, 200=100% increase of occurrence, 253=Not water
....
  plot(indonesia_cj_l1, add=TRUE, lwd=2)
  
  
  
### STEP 3: EXTRACT RASTER VALUES PER DISTRICT LEVEL POLYGON ###
  
    #obtain extracted values directly
  #gswe_recurrence_polygon_values <- exact_extract(gswe_recurrence_masked, indonesia_cj_l3) #for each district polygon, returns a data frame containing the value of each pixel and its coverage fraction (i.e. the fraction of the pixel w/in the polygon)
  
    #return summary statistics for each district polygon
  
      #water occurrence
  gswe_occurrence_polygon <- exact_extract(gswe_occurrence_masked, indonesia_cj_l3, append_cols=TRUE, quantiles=.75, c('count', 'sum', 'mode', 'mean', 'median', 'quantile', 'min', 'max', 'variety', 'variance', 'stdev', 'frac'))
  
      #recurrence
  gswe_recurrence_polygon <- exact_extract(gswe_recurrence_masked, indonesia_cj_l3, append_cols=TRUE, quantiles=.75, c('count', 'sum', 'mode', 'mean', 'median', 'quantile', 'min', 'max', 'variety', 'variance', 'stdev', 'frac'))
  
      #occurrence change intensity
  exact_extract(gswe_change_masked, indonesia_cj_l3, 'max') #has values of 253 & 254 which are coded as not water and unable to calculate, respectively, and will bias summary stats
                                                            #obtain fractional proportions of unique values instead of averages and other summary stats
  gswe_change_polygon <- exact_extract(gswe_change_masked, indonesia_cj_l3, append_cols=TRUE, c('count', 'min', 'max', 'variety', 'frac'))
  
  

  #save as Stata datasets to working directory
  
    #water occurrence
  write_dta(gswe_occurrence_polygon,
    "Working datasets/gswe_occurrence.dta")
  
    #recurrence
  write_dta(gswe_recurrence_polygon,
    "Working datasets/gswe_recurrence.dta")
  
    #occurrence change intensity
  write_dta(gswe_change_polygon,
    "Working datasets/gswe_change.dta")
  
  
