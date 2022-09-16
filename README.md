# Broadband and Equal Access to the Internet in New York City

- Finding #1: Nearly a third of New York City households lack broadband service at home and the percentage is even higher for Black, Hispanic, low-income, and senior households.
- Finding #2: For some community districts — many in the Bronx and high-poverty areas — over 40% of households do not have high-speed broadband service.
- Finding #3: Between 11 and 13 percent of NYC DOE students in each borough lacked access to adequate internet at home during remote learning.

------------------------------------------------------------------------

### Data Sources

- 2021 1-Year ACS Survey (using R library censusapi)
  - Table B28002, “Presence and Types of Internet Subscriptions in Household"
- 2020 5-Year ACS Survey (using R library censusapi)
  - Table B28002, “Presence and Types of Internet Subscriptions in Household"
  - Table S1701, “Poverty Status in the Past 12 Months”
- Public Use Microdata Sample (PUMS) 2020 5-Year ACS Survey (using R library tidycensus)
- [NYSED remote learning survey](https://github.com/new-york-civil-liberties-union/NYSED-Remote-Learning-Survey)
- [NYC Planning Community District Tabulation Areas (CDTA)](https://www1.nyc.gov/site/planning/data-maps/open-data/census-download-metadata.page)

NOTE: Broadband is defined as "Broadband (high speed) Internet service such as cable, fiber optic, or DSL service"

### Code

If code is numbered, run it in order. 

- 00_load_dependencies.R: Load libraries and common functions. 
- cdta
  - 01_census_pull_cdta.R: Pull census internet subscription, population, and poverty data at census tract level; Aggregate to community district tabulation area (CDTA); Identify CDTA's with least amount of access. 
  - 02_cdta_maps.R: Interactive and black & white maps of broadband access and poverty at the CDTA level. 
- pums
  - 01_pums_pull.R: Pull census (PUMS) data for demographics and broadband access; Create a dataframe to use for plotting. 
  - 02_pums_map.R: Map broadband access at PUMA level. 
  - 03_pums_plot.R: Create plot of access to broadband across demographic groups. 
  - 04_pums_plot_interactive.R: Create interactive plot of access to broadband across demographic groups. 
- student_survey
  - 01_student_survey.R: Plot NYC DOE student internet/device access using NYSED-Remote-Learning-Survey by County. 
  - 02_student_survey_interactive_plot.R: Make student survey plot interactive. 
 - census_pull_county.R: Pull census internet subscription and population data at county level; Aggregate to NYC.
