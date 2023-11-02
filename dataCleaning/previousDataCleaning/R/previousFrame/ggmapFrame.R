getFrame = function(timestamp) {
  posix_time <- as.POSIXct(timestamp, origin="1970-01-01", tz="UTC")
  
  # Extract the hour and minute
  hour <- format(posix_time, format="%H")
  minute <- format(posix_time, format="%M")
  
  timed_data = subset(intData, timestamps == timestamp)
  
  zoomed_points = timed_data %>% filter(lon >= bbox2[1], 
                                        lon <= bbox2[3], 
                                        lat >= bbox2[2], 
                                        lat <= bbox2[4])
  
  # Textgrob which contains information of the time
  timeGrob = textGrob(
    label = paste0("Time: ", hour, ":", minute), 
    x = 0.705,     
    y = 0.59,     
    just = c("left", "top"),     
    gp = gpar(fontsize = 140, col = "black", fontfamily = "oswald")
  )
  
  auckland_visual = ggmap(auckland_map) + 
    geom_point(data = timed_data, aes(x = lon, y= lat, color = status), size = 1.5, alpha = 0.5) +
    scale_color_manual(values = colour_scheme) +
    
    # Add a square
    annotate("rect", 
             xmin = bbox2[1], 
             xmax = bbox2[3], 
             ymin = bbox2[2], 
             ymax = bbox2[4],
             fill = NA,                   # No fill
             colour = "black",            # Outline color
             linetype = "solid",          # Type of line
             size = 1)  + 
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
    geom_point(data = zoomed_points, aes(x = lon, y= lat, color = status), size = 2.5, alpha = 0.6) +
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
                               b = -3,  # Bottom margin
                               l = -3), # Left margin
          plot.background = element_rect(color = "black", size = 1, fill = NA))
  
  # In order ot use gggrid, we need to convert our zoomed_visual into a grob
  g2 = ggplotGrob(zoomed_visual)
  outerEdge = rectGrob(gp = gpar(fill = NA, lwd = 1.5))

  vp <- viewport(x = 1, y = 1, width = unit(0.498, "npc"), height = unit(0.4, "npc"), just = c("right", "top"))
  
  frame_visual = auckland_visual + grid_panel(gTree(children = gList(g2, outerEdge), vp=vp))
  frame_visual = frame_visual + grid_panel(grobTree(timeGrob)) 
  frame_visual
  
  # Saving the plot
  filename <- paste0("frames/m", timestamp, ".png")  # Creating the filename by concatenating the timestamp with ".png"
  ggsave(filename, plot = frame_visual, width = 10, height = 8, units = "in")  # Saving the plot
  
  return(NULL)
}

