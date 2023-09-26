getFrame = function(timestamp) {
  grid.newpage()
  
  posix_time <- as.POSIXct(timestamp, origin="1970-01-01", tz="UTC")
  
  # Extract the hour and minute
  hour <- format(posix_time, format="%H")
  minute <- format(posix_time, format="%M")
  
  timed_data = subset(intData, timestamps == timestamp)
  
  zoomed_points = timed_data %>% filter(lon >= bbox2[1], 
                                        lon <= bbox2[3], 
                                        lat >= bbox2[2], 
                                        lat <= bbox2[4])
  auckland_visual = ggmap(auckland_map) + 
    geom_point(data = timed_data, aes(x = lon, y= lat, color = status), size = 1.5, alpha = 0.5) +
    scale_color_manual(values = colour_scheme) +
    
    # Add a square
    annotate("rect", 
             xmin = 174.71623867157618, 
             xmax = 174.7994086071811, 
             ymin = -36.88300601996546, 
             ymax = -36.83723524397908,
             fill = NA,                   # No fill
             colour = "black",            # Outline color
             linetype = "solid",          # Type of line
             size = 1)   +
    # Add timestamp text
    annotate("text",
             x = 174.51351991992968,     # X-coordinate of the text
             y = -36.498361075414714,     # Y-coordinate of the text
             label = paste0("Time: ", hour, ":", minute),          # The timestamp you want to display
             vjust = 1.2,                 # Vertical adjustment to position the text
             hjust = 0,                  # Horizontal adjustment to position the text
             size = 15,                   # Text size
             color = "black") + 
    # Remove x and y axes
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank(),
          # Remove the legend
          legend.position = "none",
          plot.margin = margin(t = 0,  # Top margin
                               r = 0,  # Right margin
                               b = 0,  # Bottom margin
                               l = 0)) # Left margin
  
  zoomed_visual = ggmap(auckland_central) + 
    geom_point(data = zoomed_points, aes(x = lon, y= lat, color = status), size = 3, alpha = 0.6) +
    scale_color_manual(values = colour_scheme) +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank(),
          # Remove the legend
          legend.position = "none",
          plot.margin = margin(t = 0,  # Top margin
                               r = 0,  # Right margin
                               b = 0,  # Bottom margin
                               l = 0)) # Left margin
  g1 = ggplotGrob(auckland_visual)
  g2 = ggplotGrob(zoomed_visual)
  
  # Get the bounding box of the map
  bb <- attr(auckland_map, "bb")
  
  grid.draw(g1)
  vp <- viewport(x = 1, y = 1, width = unit(0.4, "npc"), height = unit(0.32, "npc"), just = c("right", "top"))
  pushViewport(vp)
  grid.draw(g2)
  upViewport()
  
  
#  png("combined_plot.png", width = 6*300, height = 4*300, res = 300)  # the width and height are in pixels; the res is in dpi
#  combined_plot()
#  dev.off()
}



