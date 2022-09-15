# https://walker-data.com/tidycensus/articles/pums-data.html

source("code/00_load_dependencies.R")

### SUMMARY ------------
# Pull census (PUMS) data for demographics and broadband access
# Create a dataframe to use for plotting

### Pull and clean data -----------

pums_vars_2020 <- pums_variables %>% 
  filter(year == 2020, survey == "acs5")

# pums_variables contains both the variables as well as their possible values. So let’s just look at the unique variables.
pums_vars_2020 %>% 
  distinct(var_code, var_label, data_type, level)

### HISPEED ------------------

# puma shapefile
url <- "https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nypuma2010_22a.zip"
nyc_puma <- read_sf(unzip_sf(url)) %>%
  mutate(
    PUMA = paste0("0", PUMA)
  )


ny_pums_hispeed <- get_pums(
  variables = c("PUMA", "HISPEED", "RAC1P", "HISP", "AGEP", "POVPIP"),
  state = "NY",
  survey = "acs5",
  year = 2020, 
  # do not include vacant housing units
  return_vacant = FALSE,
  # recode character variables
  recode = TRUE, 
  # for standard errors: replicate weights are used to simulate multiple samples from the single PUMS sample and can be used 
  # to calculate more precise standard errors. PUMS data contains both person- and housing-unit-level replicate weights.
#  rep_weights = "housing"
  ) %>%
  filter(
    SPORDER == "1"
  ) %>%
  mutate(
    race_ethnicity = case_when(
      HISP != "01" ~ "Hispanic",
      HISP == "01" & RAC1P == "1" ~ "White",
      HISP == "01" & RAC1P == "2" ~ "Black",
      TRUE ~ "Other"
    ), 
    age65plus = case_when(
      AGEP >= 65 ~ "Senior",
      TRUE ~ "Other"
    ), 
    poverty = case_when(
      POVPIP < 200 ~ "low-income",
      TRUE ~ "Other"
    )
  )

# nyc totals
nyc_puma %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  summarize(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop, 
    no_speed = sum(WGTP[HISPEED == "2"]),
    no_speed_pct = no_speed / total_pop, 
    na_speed = sum(WGTP[HISPEED == "b"]),
    na_speed_pct = na_speed / total_pop, 
  )

overall <- nyc_puma %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  summarize(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>% 
  select(hi_speed_pct) %>%
  as.numeric()

# nyc pums broadband -> use for map in 02_pums_map.R
nyc_pums_hispeed <- nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(PUMA) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>%
  left_join(nyc_puma %>% select(PUMA), by = "PUMA") %>%
  st_as_sf() %>%
  st_transform("+proj=longlat +datum=WGS84") 
  

### by race ------ 

# nyc total
nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(race_ethnicity) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) 

race_black <- nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(race_ethnicity) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>%
  filter(race_ethnicity == "Black") %>%
  select(hi_speed_pct) %>%
  as.numeric()

race_hispanic <- nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(race_ethnicity) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>%
  filter(race_ethnicity == "Hispanic") %>%
  select(hi_speed_pct) %>%
  as.numeric()

# puma [prob don't need]
nyc_race_hispeed <- nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(PUMA, race_ethnicity) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>%
  left_join(nyc_puma %>% select(PUMA), by = "PUMA") %>%
  st_as_sf()

### by age ------ 

# nyc total
nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(age65plus) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) 

age <- nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(age65plus) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>%
  filter(age65plus == "Senior") %>%
  select(hi_speed_pct) %>%
  as.numeric()

  
### by poverty ------ 

# nyc total
nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(poverty) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) 

poverty <- nyc_puma %>%
  select(PUMA) %>%
  st_drop_geometry() %>%
  left_join(ny_pums_hispeed, by = "PUMA") %>%
  group_by(poverty) %>%
  summarise(
    total_pop = sum(WGTP),
    hi_speed = sum(WGTP[HISPEED == "1"]),
    hi_speed_pct = hi_speed / total_pop
  ) %>%
  filter(poverty == "low-income") %>%
  select(hi_speed_pct) %>%
  as.numeric()

### put hispeed metric together for plot -> use for plot in 03_pums_plot.R
plot_df <- as.data.frame(matrix(nrow = 5, ncol = 2)) %>%
  rename(
    group = V1,
    hi_speed_pct = V2
    )

plot_df[1,] <- c("NYC Average", round(0.283 * 100, 2)) # Use 28.3 from the census_pull_country.R
plot_df[2,] <- c("Black", round(100 - (race_black * 100), 2))
plot_df[3,] <- c("Hispanic", round(100 - (race_hispanic * 100), 2))
plot_df[4,] <- c("Low-Income", round(100 - (poverty * 100), 2))
plot_df[5,] <- c("Seniors (65+)", round(100 - (age * 100), 2))

plot_df <- plot_df %>%
  mutate(hi_speed_pct = as.numeric(hi_speed_pct))

