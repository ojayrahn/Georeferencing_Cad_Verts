###Reading in Polygons, Setting CRS, Calculating Area and Centroid###

#loading the libraries that we need
library(tidyverse)
library(sf)
library(geodata)

####################################################################
#####First, read in a folder of polygons you want to work with######
####################################################################

#set the text in quotations to the folder that contains the polygons you want to work with
baseDir <- "./Tester_2/" #@myself change file path once done  testing
filenames <- list.files("./Tester_2", pattern=".shp") #change file path once done testing
#might want to change above to pattern= c(".shp",".kml",".gdb")
filepaths <- paste(baseDir, filenames, sep='')

#Read each shapefile and return a list of sf objects
listOfShp <- lapply(filepaths, st_read) 

#we should check crs information here before merging polygons FIX THIS!!!!!!
crs_id <- st_crs(listOfShp) 
view(crs_id) 
#this doesn't really work because we can't see the crs information for a list or a vector
#we can only see it once its a multipolygon 

#repojecting into a common crs so that we can merge as one multipolygon
listOfShp_reproj <- lapply(listOfShp, function(x) {st_crs(x) <- 3977; x})

# Combine the list of sf objects into a single object
allpolys <- do.call(what = sf:::rbind.sf, args=listOfShp_reproj)

########################
#####Calculate Areas####
########################

#calculating area for each polygon in the allpolys multipolygon 
allpolys$area_sqkm <- st_area(allpolys) 
#checking to make sure that there are the same number of unique values as there are polygons in allpolys (13 in the case of the tester files)
unique(allpolys$area_sqkm) 

#######################
##Calculate Centroids##
#######################

#calculate centroid
allpolys$centroid <- st_centroid(allpolys)  #okay this is working and creating centroid geometry columns
allpolys$centroid

plot(allpolys$centroid[1]) #this plot is not good but the points are appearing in the general shape of Canada so that is promising
#under here will probably want to have a line of code that properly plots a map so people can check if the centroids make sense

################################
##Extract Centroid Coordinates##
################################
centroid_only <- allpolys$centroid

#this lets us extract the centroid lat/long from the polygon that's been created
centroid_coordinates <- lapply(centroid_only,st_centroid_coords)

################################
####Plot Basemap for Centroid###
################################

#need to figure out how to reproject this still 

#load canadian basemap (but this can be done for every country)
canada <- gadm(country = "CAN", level = 1, resolution = 2,
               path = "...Tester_2/")
plot(canada, add=TRUE)

#think we need to reproject the map
canada_reproj <- st_set_crs(canada, "EPSG:3977") #still need to fix this part

################################
#####Calculating Area Bins######
################################

#creating a categorical variable for area
area <- allpolys$area_sqkm
allpolys$area_bin <- as.factor(ifelse(area<10, '<10',
                                      ifelse(area<100, '<100',
                                             ifelse(area<1000, '<1000',
                                                    ifelse(area<10000, '<10000', 
                                                           ifelse(area<100000,'<100000',
                                                                  '>100000'))))))












