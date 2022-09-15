# Broadband and Equal Access to the Internet in New York City

-   High-speed broadband internet service in New York City remains divided across boroughs and neighborhoods.
-   For some areas, over 40% of residents do not have high-speed broadband service.
-   The Bronx stands out having many neighborhoods with 37% or more households without broadband internet.

------------------------------------------------------------------------

### Data Sources

- 2020 5-Year ACS Survey (using R library censusapi)
  - Table B28002, “Presence and Types of Internet Subscriptions in Household"
  - Table S1701, “Poverty Status in the Past 12 Months”

- Public Use Microdata Sample (PUMS) 2020 5-Year ACS Survey (using R library tidycensus)
- [NYSED remote learning survey](https://github.com/new-york-civil-liberties-union/NYSED-Remote-Learning-Survey)
- [NYC Planning Community District Tabulation Areas (CDTA)](https://www1.nyc.gov/site/planning/data-maps/open-data/census-download-metadata.page)

### Code

If code is numbered, run it in order. 

- 00_load_dependencies.R: Load libraries and common functions. 
- cdta
  - 01_census_pull_cdta.R: # Pull census internet subscription, population, and poverty data at census tract level; Aggregate to community district tabulation area (CDTA); Identify CDTA's with least amount of access. 
  - 02_cdta_maps.R: Interactive and black & white maps of broadband access and poverty at the CDTA level. 
- pums
  - 01_pums_pull.R: # Pull census (PUMS) data for demographics and broadband access; Create a dataframe to use for plotting. 
  - 02_pums_map.R: Map broadband access at PUMA level. 
  - 03_pums_plot.R: Create plot of access to broadband across demographic groups. 
  - 04_pums_plot_interactive.R: Create interactive plot of access to broadband across demographic groups. 
 - student_survey
  - 01_student_survey.R: Plot NYC DOE student internet/device access using NYSED-Remote-Learning-Survey by County. 
  - 02_student_survey_interactive_plot.R: Make student survey plot interactive. 
 - census_pull_county.R: # Pull census internet subscription and population data at county level; Aggregate to NYC.
