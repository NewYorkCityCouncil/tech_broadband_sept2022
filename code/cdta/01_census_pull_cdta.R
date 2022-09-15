
source("code/00_load_dependencies.R")

### SUMMARY ------------
# Pull census internet subscription, population, and poverty data at census tract level 
# Aggregate to community district tabulation area (CDTA)
# Identify CDTA's with least amount of access 

### Pull and clean data -----------
### PRESENCE AND TYPES OF INTERNET SUBSCRIPTIONS IN HOUSEHOLD -----------

# get variables available in B28002 group of ACS5 2020
# also here: https://api.census.gov/data/2020/acs/acs5/variables.html
group_B28002 <- listCensusMetadata(
  name = "acs/acs5",
  vintage = 2020,
  type = "variables",
  group = "B28002")

# relevant "PRESENCE OF A COMPUTER AND TYPE OF INTERNET SUBSCRIPTION IN HOUSEHOLD" variables
# Note: overall population is "broadband such as cable, fiber optic or DSL" while others are "broadband subscription"
vars <- c("NAME", "GEO_ID", 
          ## these are household data (e.g. "B28002_001E" = 3.192 households in nyc)
          "B28002_001E",
          # broadband (any type)
          "B28002_004E",
          # broadband for overall population (total, broadband such as cable, fiber optic or DSL); number used in internet master plan
          "B28002_007E", 
          # %s of households with only a mobile phone internet connection, only a home internet connection
          "B28002_005E", "B28002_006E", "B28002_008E", "B28002_010E", "B28002_011E", 
          # % of households citywide that have no internet access at home at all
          "B28002_013E"
          ) 

# get available geographies for ACS5 2020
geos <- listCensusMetadata(name = "acs/acs5", vintage = 2020, type = "geographies")

### data by census tract (2020) -----------

# get variables for NYC by census tract
B28002_ct <- getCensus(
  # must add a census api key
  key = Sys.getenv("KEY"),
  name = "acs/acs5",
  vintage = 2020,
  vars = vars, 
  region = "tract:*", 
  regionin = "state:36+county:005,047,081,085,061")

S1701_ct <- getCensus(
  name = "acs/acs5/subject",
  vintage = 2020,
  vars = c('NAME', 'GEO_ID',
           # Population for whom poverty status is determined
           "S1701_C01_001E",
           # individuals with income below 200 percent of poverty level
           "S1701_C01_042E"), 
  region = "tract:*", 
  regionin = "state:36+county:005,047,081,085,061")

internet_ct <- B28002_ct %>%
  left_join(S1701_ct %>% select(GEO_ID, S1701_C01_001E, S1701_C01_042E), by = "GEO_ID")

# Load CDTA shp data
cdta_url <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nycdta2020_22a.zip" 
x <- read_sf(unzip_sf(cdta_url)) 

cdta_shp <- x %>%
  st_transform("+proj=longlat +datum=WGS84") 

# create list of non-park CDTAs
cdta_df <- cdta_shp %>%
  st_drop_geometry() %>%
  # filter out parks
  filter(CDTAType == 0) %>%
  select(BoroName, CDTA2020, CDTAName)

# download and read census tract to cdta crosswalk
# download.file("https://www1.nyc.gov/assets/planning/download/office/planning-level/nyc-population/census2020/nyc2020census_tract_nta_cdta_relationships.xlsx?r=092221", destfile = "data/nyc_ct_cdta_crosswalk.xlsx")
cross_ct_cdta <- readxl::read_xlsx("data/nyc2020census_tract_nta_cdta_relationships.xlsx", sheet = "NYC_CT2020_Relate") %>%
  rename(CDTA2020 = CDTACode, 
         GEO_ID = GEOID) %>%
  mutate(GEO_ID = paste0("1400000US", GEO_ID)) %>%
  select(GEO_ID, BoroName, CDTA2020, CDTAType, CDTAName)

internet_ct_cdta <- internet_ct %>%
  left_join(cross_ct_cdta, by = "GEO_ID")

# Note: numbers match pop factfinder for CDTA
internet_cdta <- internet_ct_cdta %>%
  group_by(CDTA2020, CDTAName) %>%
  summarise(
    # no internet access (note: it is access not subscription because there is another category for access but no subscription)
    no_access = sum(B28002_013E) / sum(B28002_001E),
    # no broadband subscription any type
    no_broadband_anytype = 1 - (sum(B28002_004E) / sum(B28002_001E)),
    # no broadband subscription: 1 - proportion of with broadband such as cable, fiber optic or DSL
    no_broadband = 1 - (sum(B28002_007E) / sum(B28002_001E)),
    # cellular data plan and other internet subscription
    cell_and_int = (sum(B28002_005E) - sum(B28002_006E)) / sum(B28002_001E),
    # only cellular data plan with no other type of Internet subscription
    cell_only = sum(B28002_006E) / sum(B28002_001E), 
    # only home internet connection (broadband + satellite + other subscription)
    homeint_only = (sum(B28002_008E) + sum(B28002_010E) + sum(B28002_011E)) / sum(B28002_001E),
    # neither home broadband nor cell 
    
    # 200% of poverty level
    poverty = sum(S1701_C01_042E) / sum(S1701_C01_001E)
  )

internet_cdta_shp <- internet_cdta %>%
  left_join(cdta_shp %>% select(CDTA2020, CDTAType), by = "CDTA2020") %>%
  filter(CDTAType == "0") %>%
  st_as_sf()

### Top 5 CDTA's 

internet_cdta_shp %>% 
  arrange(desc(no_broadband)) %>%
  head(n=10)
  
internet_cdta_shp %>% 
  arrange(desc(poverty)) %>%
  head()
