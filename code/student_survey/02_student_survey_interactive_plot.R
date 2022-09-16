### Plot

source("code/student_survey/01_student_survey.R")

### SUMMARY ------------
# Make student survey plot interactive

### Interactive plot -----------
plot <- 
  ggplot(data=plot_df, aes(x=reorder(county, -lack_pct), y=lack_pct, fill=type)) +
  geom_bar_interactive(
    stat="identity", position="dodge",width = .6, 
    tooltip = paste0(
      "Borough: ", plot_df$county,
      "\n", 
      "Percent Without Access: ", round(plot_df$lack_pct, 1), "%", 
      "\n", 
      "Type: ", plot_df$type
    )
  ) + 
  labs( 
    x = "", 
    y = "Percent Without Access", 
    title = "NYC DOE Students Lack of Access to Adequate Internet / Device", 
    fill = "",
    subtitle = "About 11 to 13 percent of NYC DOE students in each borough lacked access to adequate internet in Fall 2020", 
    caption = "Source: NYSED survey conducted in Fall 2020 about student access to devices and internet.\nNYCLU obtained the survey via a Freedom of Information Law request."
  ) +
  geom_text(aes(label = paste0(round(lack_pct, 0), "%")), 
            position = position_dodge(width = 0.5), 
            vjust = 0.5, hjust = -0.25, size = 5) +
  scale_y_continuous(
    breaks = c(0, 5, 10, 15, 20),
    label = c("0%", "5%", "10%", "15%", "20%"), 
    limits = c(0,20)
  ) + 
  scale_fill_manual(values = c("#FAA916", "#2F56A6")) +
  theme(legend.position="top", 
        plot.caption = element_text(size = 10),
        legend.text = element_text(size=13),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        #panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "#E6E6E6"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "#666666"),
        axis.title.x = element_text(size = 14, 
                                    margin = 
                                      margin(t = 10, r = 0, b = 0, l = 0)),
        #        text = element_text(family = "Open Sans"),
        axis.text.y = element_text(size = 14, 
                                   margin = margin(t = 0, r = 10, b = 0, l = 0)),
        
        axis.text.x = element_text(size = 15, 
                                   margin = margin(t = 10, r = 0, b = 0, l = 0)),
        plot.subtitle=element_text(size=14),
        plot.title = element_text(family = "Georgia",size = 16)) +
  coord_flip()

tooltip_css <- "background-color:#CACACA;"

plot_interactive <- girafe(ggobj = plot,   
                           width_svg = 9.5,
                           height_svg = 8, 
                           options = list(
                             opts_tooltip(css = tooltip_css)
                           )
)

htmltools::save_html(plot_interactive, "visuals/student_access.html")
