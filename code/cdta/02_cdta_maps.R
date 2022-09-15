### Map

### SUMMARY ------------
# Map broadband access and poverty at the CDTA level
# Interactive and black and white maps

### Pull data from previous script -----------
# Have to add census api first
source("code/cdta/01_census_pull_cdta.R")

### map by CDTA - broadband ------------

# source control
rr <- HTML('<small> Source: Census ACS 5-Year 2020 Table B28002, NYC Planning CDTA </small>')

labels_broadband <- paste0("<h3>",paste0(internet_cdta_shp$CDTAName),"</h3>",
                "<p>","Households Without Broadband: ",round(internet_cdta_shp$no_broadband * 100, 0), "%", "</p>")


# histogram of data to choose breaks
hist(internet_cdta_shp$no_broadband, breaks = 15)

nat_intvl_no_broadband = classInt::classIntervals(internet_cdta_shp$no_broadband * 100, n = 5, style = 'jenks')

pal_broadband_cdta = colorBin(
  palette = c('#d5dded', '#afb9db', '#8996ca', '#6175b8', '#2f56a6'),
  bins = c(round(nat_intvl_no_broadband$brks,0)[1], round(nat_intvl_no_broadband$brks,0)[2:5], round(nat_intvl_no_broadband$brks,0)[6]+1),
  domain = (1 - internet_cdta_shp$no_broadband) * 100, 
  na.color = "Grey"
)

map <- leaflet(options = leafletOptions(zoomControl = FALSE, minZoom = 10, maxZoom = 16)) %>%
  setView(-73.941281,40.704103, zoom=10) %>% 
  addPolygons(data = internet_cdta_shp, 
              weight = 1,
              color = "white",
              stroke = TRUE,
              fillColor = ~pal_broadband_cdta(internet_cdta_shp$no_broadband * 100),
              fillOpacity = 0.9, 
              label = lapply(labels_broadband,HTML)) %>% 
  addLegend(position ="topleft", 
            pal = pal_broadband_cdta, 
            opacity = 0.9,
            values = internet_cdta_shp$no_broadband * 100,
            title =  "Percent of Households Without</br>High Speed Broadband Access</br>In Each Community District",
            labFormat = labelFormat(suffix = "%")) %>%
  setMapWidgetStyle(list(background= "white")) %>% 
  addControl(rr, position = "bottomright")
  
map

pal_bw_broadband_cdta = colorBin(
  palette = grey(seq(0.8,0.1,length.out=5)),
  bins = c(round(nat_intvl_no_broadband$brks,0)[1], round(nat_intvl_no_broadband$brks,0)[2:5], round(nat_intvl_no_broadband$brks,0)[6]+1),
  domain = (1 - internet_cdta_shp$no_broadband) * 100, 
  na.color = "Grey"
)

map_bw <- leaflet() %>%
  setView(-73.941281,40.704103, zoom=10) %>% 
  addPolygons(data = internet_cdta_shp, 
              weight = 1,
              color = "white",
              stroke = TRUE,
              fillColor = ~pal_bw_broadband_cdta(internet_cdta_shp$no_broadband * 100),
              fillOpacity = 0.9, 
              label = lapply(labels_broadband,HTML)) %>% 
  addLegend(position ="topleft", 
            pal = pal_bw_broadband_cdta, 
            opacity = 0.9,
            values = internet_cdta_shp$no_broadband * 100,
            title =  "Percent of Households Without</br>High Speed Broadband Access</br>In Each Community District",
            labFormat = labelFormat(suffix = "%")) %>%
  setMapWidgetStyle(list(background= "white")) %>% 
  addControl(rr, position = "bottomright")

map_bw

saveWidget(map, file="visuals/map_broadband_cdta.html")

mapshot(map_bw, file = "visuals/map_broadband_cdta.png", 
        vwidth = 900, vheight = 870)


### map by CDTA - poverty ------------

# source control
rr <- HTML('<small> Source: Census ACS 5-Year 2020 Table S1701, NYC Planning CDTA </small>')

labels_poverty <- paste0("<h3>",paste0(internet_cdta_shp$CDTAName),"</h3>",
                 "<p>","Income Below 200% of Poverty Level: ",round(internet_cdta_shp$poverty * 100, 0), "%", "</p>")


# histogram of data to choose breaks
hist(internet_cdta_shp$poverty, breaks = 15)

nat_intvl_poverty = classInt::classIntervals(internet_cdta_shp$poverty * 100, n = 5, style = 'jenks')

pal_poverty_cdta = colorBin(
  palette = c('#d5dded', '#afb9db', '#8996ca', '#6175b8', '#2f56a6'),
  bins = c(round(nat_intvl_poverty$brks,0)[1], round(nat_intvl_poverty$brks,0)[2:5], round(nat_intvl_poverty$brks,0)[6]+1),
  domain = (1 - internet_cdta_shp$poverty) * 100, 
  na.color = "Grey"
)

map <- leaflet(options = leafletOptions(zoomControl = FALSE, minZoom = 10, maxZoom = 16)) %>%
  setView(-73.941281,40.704103, zoom=10) %>% 
  addPolygons(data = internet_cdta_shp, 
              weight = 1,
              color = "white",
              stroke = TRUE,
              fillColor = ~pal_poverty_cdta(internet_cdta_shp$poverty * 100),
              fillOpacity = 0.9, 
              label = lapply(labels_poverty,HTML)) %>% 
  addLegend(position ="topleft", 
            pal = pal_poverty_cdta, 
            opacity = 0.9,
            values = internet_cdta_shp$poverty * 100,
            title =  "Percent of Individuals</br>Below 200% of Poverty Level</br>In Each Community District",
            labFormat = labelFormat(suffix = "%")) %>%
  setMapWidgetStyle(list(background= "white")) %>% 
  addControl(rr, position = "bottomright")


map

pal_bw_poverty_cdta = colorBin(
  palette = grey(seq(0.8,0.1,length.out=5)),
  bins = c(round(nat_intvl_poverty$brks,0)[1], round(nat_intvl_poverty$brks,0)[2:5], round(nat_intvl_poverty$brks,0)[6]+1),
  domain = (1 - internet_cdta_shp$poverty) * 100, 
  na.color = "Grey"
)

map_bw <- leaflet() %>%
  setView(-73.941281,40.704103, zoom=10) %>% 
  addPolygons(data = internet_cdta_shp, 
              weight = 1,
              color = "white",
              stroke = TRUE,
              fillColor = ~pal_bw_poverty_cdta(internet_cdta_shp$poverty * 100),
              fillOpacity = 0.9, 
              label = lapply(labels_poverty,HTML)) %>% 
  addLegend(position ="topleft", 
            pal = pal_bw_poverty_cdta, 
            opacity = 0.9,
            values = internet_cdta_shp$poverty * 100,
            title =  "Percent of Individuals</br>Below 200% of Poverty Level</br>In Each Community District",
            labFormat = labelFormat(suffix = "%")) %>%
  setMapWidgetStyle(list(background= "white")) %>% 
  addControl(rr, position = "bottomright")

map_bw

saveWidget(map, file="visuals/map_poverty_cdta.html")

mapshot(map_bw, file = "visuals/map_poverty_cdta.png", 
        vwidth = 900, vheight = 870)

