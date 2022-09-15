
source("code/00_load_dependencies.R")

### SUMMARY ------------
# Pull census internet subscription and population data at county level 
# Aggregate to NYC

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
          # broadband for overall population (total, broadband such as cable, fiber optic or DSL)
          "B28002_007E", 
          # %s of households with only a mobile phone internet connection, only a home internet connection
          "B28002_005E", "B28002_006E", "B28002_008E", "B28002_010E", "B28002_011E", 
          # % of households citywide that have no internet access at home at all
          "B28002_013E"
          ) 

# get available geographies for ACS5 2020
geos <- listCensusMetadata(name = "acs/acs5", vintage = 2020, type = "geographies")

### data by county (2020) -----------

# get variables for NYC by county
internet_county <- getCensus(
  # must add a census api key
  key = Sys.getenv("KEY"),
  name = "acs/acs5",
  vintage = 2020,
  vars = vars, 
  region = "county:005,047,081,085,061", 
  regionin = "state:36")

internet_nyc <- internet_county %>%
  group_by(state) %>%
  summarise(
    # no internet access (note: it is access not subscription because there is another category for access but no subscription)
    no_access = sum(B28002_013E) / sum(B28002_001E),
    # no broadband subscription: 1 - proportion of with broadband such as cable, fiber optic or DSL
    no_broadband = 1 - (sum(B28002_007E) / sum(B28002_001E)),
    # cellular data plan and other internet subscription
    cell_and_int = (sum(B28002_005E) - sum(B28002_006E)) / sum(B28002_001E),
    # only cellular data plan with no other type of Internet subscription
    cell_only = sum(B28002_006E) / sum(B28002_001E), 
    # only home internet connection (broadband + satellite + other subscription)
    homeint_only = (sum(B28002_008E) + sum(B28002_010E) + sum(B28002_011E)) / sum(B28002_001E),
    # neither home broadband nor cell 

  )



