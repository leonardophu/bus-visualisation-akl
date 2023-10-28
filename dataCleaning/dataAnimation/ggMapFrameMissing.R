getFrameMissing = function(timestamp, filepath = "frames/") {
  posix_time <- as.POSIXct(timestamp, origin="1970-01-01", tz="UTC")
  
  # Extract the hour and minute
  hour <- format(posix_time, format="%H")
  minute <- format(posix_time, format="%M")
  
  # Points for current timestamp
  timed_data = subset(intData, timestamps == timestamp)
  # Later bus gets plotted on later. Missing buses get placed first
  timed_data = timed_data %>%
    mutate(status = factor(status, levels = c(1, 2, 3, 0))) %>%
    arrange(status)
  
  # Zoomed points for current timestamp
  zoomed_points = timed_data %>% filter(lon >= bbox2$ll.lon, 
                                        lon <= bbox2$ur.lon, 
                                        lat >= bbox2$ll.lat, 
                                        lat <= bbox2$ur.lat)
  
  # Textgrob which contains information of the time
  timeGrob = textGrob(
    label = paste0("Time: ", hour, ":", minute), 
    x = 0.645,     
    y = 0.61,     
    just = c("left", "top"),     
    gp = gpar(fontsize = 140, col = "black", fontfamily = "oswald")
  )
  
  # Big map creation
  auckland_visual = ggmap(auckland_map) + 
    geom_point(data = timed_data, 
               aes(x = lon, y = lat, color = status, alpha = as.factor(status)), 
               size = 1.5) +
    # More relevant points get less transparancy (e.g. Late buses less transparent)
    scale_alpha_manual(values = c('0' = 0.8, '1' = 0.3, '2' = 0.9, '3' = 0.7)) +
    scale_color_manual(values = colour_scheme) +
    
    # Add a square for zoomed in area
    annotate("rect", 
             xmin = bbox2$ll.lon, 
             xmax = bbox2$ur.lon, 
             ymin = bbox2$ll.lat, 
             ymax = bbox2$ur.lat,
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
  
  # Zoomed visual 
  zoomed_visual = ggmap(auckland_central) + 
    geom_point(data = zoomed_points, 
               aes(x = lon, y = lat, color = status, alpha = as.factor(status)), 
               size = 2) +
    scale_alpha_manual(values = c('0' = 0.8, '1' = 0.3, '2' = 0.7, '3' = 0.7)) +
    scale_color_manual(values = colour_scheme) +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank(),
          # Remove the legend
          legend.position = "none",
          # Depending on border level, change margins to remove white space 
          plot.margin = margin(t = 0,  # Top margin
                               r = 0,  # Right margin
                               b = -3,  # Bottom margin
                               l = -3)) # Left margin
  
  # In order to use gggrid, convert zoomed_visual to grob
  g2 = ggplotGrob(zoomed_visual)
  # Box for zoomed visual
  outerEdge = rectGrob(gp = gpar(fill = NA, lwd = 1.5))
  
  # Viewport for zoomed visual
  vp <- viewport(x = 1, y = 1, width = unit(0.38, "npc"), height = unit(0.38, "npc"), just = c("right", "top"))
  
  # Creating our final visualisation
  frame_visual = auckland_visual + grid_panel(gTree(children = gList(g2, outerEdge), vp=vp))
  frame_visual = frame_visual + grid_panel(grobTree(timeGrob)) 
  frame_visual
  
  # Saving the plot
  filename <- paste0(filepath, "m",  timestamp, ".png")  # Creating the filename by concatenating the timestamp with ".png"
  ggsave(filename, plot = frame_visual, width = 10, height = 8, units = "in")  # Saving the plot
  
  return(NULL)
}

