# Digital Divide

Broadband access in NYC

* High-speed broadband internet service in New York City remains divided across boroughs and neighborhoods.
* For some areas, over 40% of residents do not have high-speed broadband service.
* The Bronx stands out having many neighborhoods with 37% or more households without broadband internet.

***   


### Data Sources 
- PUMS 2019 5-Year ACS Survey (using R library tidycensus)

### Code

Code is numbered in the order that they are run. 

- 01_pums_pull.R: Pull and clean PUMS data.  Calculate high-speed broadband service access by relevant demographics. 
- 02_pums_map.R: Map high-speed broadband service by PUMA. Create visual/map_puma.html and visual/map_puma.png. 
- 03_pums_plot.R: Create group_comparison.png chart showing differences in access by demographic groups. 

