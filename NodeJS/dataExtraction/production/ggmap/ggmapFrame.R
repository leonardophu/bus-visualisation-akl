getFrame = function(timestamp) {
  grid.newpage()
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
  
  print(auckland_visual)
  vp <- viewport(x=0.85, y=1, width=.4, height=.4,
                 just=c("right", "top"))
  pushViewport(vp)
  print(zoomed_visual, newpage = FALSE)
  upViewport()
}

