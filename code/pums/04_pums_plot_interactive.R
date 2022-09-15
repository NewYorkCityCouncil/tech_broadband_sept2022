### Plot

### SUMMARY ------------
# Create interactive plot of access to broadband across demographic groups

### Pull data from previous script -----------
# Have to add census api first
source("code/pums/01_pums_pull.R")


### plot by PUMA ------------

plot <- ggplot(data=plot_df, aes(x=reorder(group, -hi_speed_pct), y=hi_speed_pct)) +
  geom_bar_interactive(stat="identity", width = .6, fill = "#2F56A6", 
           tooltip = paste0(
             "Group: ", plot_df$group,
             "\n", 
             "Percent of Households Without Broadband: ", round(plot_df$hi_speed_pct, 1)
             )
           ) + 
  labs( 
    x = "", 
    y = "Percent of Households Without Broadband (High-Speed) Internet service", 
    title = "Lack of Broadband (High-Speed) Internet Access in NYC by Group", 
    subtitle = "Black, Hispanic, low-income, and senior residents have less access to broadband compared to the NYC average", 
    caption = "Source: ACS 5-Year 2020 (PUMS)"
    ) +
  geom_text(show.legend = F,
            label= paste0(round(plot_df$hi_speed_pct, 0), "%"), 
            nudge_x = 0, nudge_y = 1.5
  ) + 
  scale_y_continuous(
    breaks = c(0, 10, 20, 30, 40, 50),
    label = c("0%", "10%", "20%", "30%", "40%", "50%")
  ) +
  theme(legend.position="none", 
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

tooltip_css <- "background-color:#CACACA;"

plot_interactive <- girafe(ggobj = plot,   
                           width_svg = 11,
                           height_svg = 8, 
                           options = list(
                             opts_tooltip(css = tooltip_css)
                           )
)

htmltools::save_html(plot_interactive, "visuals/group_comparison.html")

