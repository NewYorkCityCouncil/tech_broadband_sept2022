### Plot

source("code/00_load_dependencies.R")

### SUMMARY ------------
# Plot NYC DOE student internet/device access using NYSED-Remote-Learning-Survey by County

### Pull and clean data -----------
# https://github.com/new-york-civil-liberties-union/NYSED-Remote-Learning-Survey
og_df <- read.csv("https://raw.githubusercontent.com/new-york-civil-liberties-union/NYSED-Remote-Learning-Survey/main/Results%20in%20CSV%20format/Survey%20Results%20by%20School.csv", header = TRUE) %>%
  janitor::clean_names()

survey_results_by_school <- og_df %>%
  mutate(
    internet_access_rate = as.numeric(str_replace_all(internet_access_rate, "%", "")),
    device_access_rate = as.numeric(str_replace_all(device_access_rate, "%", "")),
    provided_internet_rate = as.numeric(str_replace_all(provided_internet_rate, "%", "")),
    provided_device_rate = as.numeric(str_replace_all(provided_device_rate, "%", "")),
    white_percentage = as.numeric(str_replace_all(white_percentage, "%", "")),
    black_percentage = as.numeric(str_replace_all(black_percentage, "%", "")),
    latinx_percentage = as.numeric(str_replace_all(latinx_percentage, "%", "")),
    asian_percentage = as.numeric(str_replace_all(asian_percentage, "%", "")),
    native_percentage = as.numeric(str_replace_all(native_percentage, "%", "")),
    multiracial_percentage = as.numeric(str_replace_all(multiracial_percentage, "%", "")),
  ) %>%
  filter(
    county %in% c("BRONX", "NEW YORK", "KINGS", "QUEENS", "RICHMOND"), 
    district_name == "NYC DOE"
  )

# 114,073 (13%) students lacked adequate access to internet and 125,594 (14%) students lacked adequate access to a device
doe_nyc <- survey_results_by_school %>%
  summarise(
    schools = n(), 
    enrollment = sum(enrollment_total), 
    lack_internet_sum = sum(lack_internet_total),
    lack_internet_pct = (lack_internet_sum / enrollment) * 100, 
    lack_device_sum = sum(lack_device_total),
    lack_device_pct = (lack_device_sum / enrollment) * 100
  )

doe_by_county <- survey_results_by_school %>%
  group_by(county) %>%
  summarise(
    schools = n(), 
    enrollment = sum(enrollment_total), 
    lack_internet_sum = sum(lack_internet_total),
    lack_internet_pct = (lack_internet_sum / enrollment) * 100, 
    lack_device_sum = sum(lack_device_total),
    lack_device_pct = (lack_device_sum / enrollment) * 100
    )

plot_df <- doe_by_county %>%
  select(county, lack_internet_pct) %>%
  mutate(
    type = "internet"
  ) %>%
  rename(
    lack_pct = lack_internet_pct
  ) %>%
  rbind(
    doe_by_county %>%
      select(county, lack_device_pct) %>%
      mutate(
        type = "device"
      ) %>%
      rename(
        lack_pct = lack_device_pct
      )
  ) %>%
  mutate(
    county = case_when(
      county == "NEW YORK" ~ "Manhattan", 
      county == "BRONX" ~ "Bronx", 
      county == "QUEENS" ~ "Queens", 
      county == "RICHMOND" ~ "Staten Island", 
      county == "KINGS" ~ "Brooklyn"
    ), 
    type = case_when(
      type == "device" ~ "Device", 
      type == "internet" ~ "Internet"
    )
  )

### plot of lack of internet access by county ------------

p <- ggplot(data=plot_df, aes(x=reorder(county, -lack_pct), y=lack_pct, fill=type)) +
  geom_bar(stat="identity", position="dodge",width = .6) + 
  labs( 
    x = "", 
    y = "Percent Without Access", 
    title = "NYC DOE Students Lack of Access to Adequate Internet / Device", 
    fill = "",
    subtitle = "11 - 13 percent of NYC DOE students in each borough lacked access to adequate internet in Fall 2020", 
    caption = "Source: NYSED survey conducted in Fall 2020 about student access to devices and internet\nobtained by the NYCLU via a Freedom of Information Law request"
  ) +
  geom_text(aes(label = paste0(round(lack_pct, 0), "%")), position = position_dodge(width = 0.5), vjust = 0.5, hjust = -0.25) +
  scale_y_continuous(
    breaks = c(0, 5, 10, 15, 20),
    label = c("0%", "5%", "10%", "15%", "20%"), 
    limits = c(0,20)
  ) + 
  scale_fill_manual(values = c("#FAA916", "#2F56A6")) +
  theme(legend.position="top", 
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        #panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "#E6E6E6"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "#666666"),
        axis.title.x = element_text(margin = 
                                      margin(t = 10, r = 0, b = 0, l = 0)),
        #        text = element_text(family = "Open Sans"),
        axis.text.y = element_text(size = 14, 
                                   margin = margin(t = 0, r = 10, b = 0, l = 0)),
        
        axis.text.x = element_text(size = 12, 
                                   margin = margin(t = 10, r = 0, b = 0, l = 0)),
        plot.subtitle=element_text(size=12),
        plot.title = element_text(family = "Georgia",size = 16)) +
  coord_flip()

p

ggsave(p, filename = "visuals/student_access.png", 
       units = c("in"), width= 10, height= 6)

